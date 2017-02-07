import 'dart:html';
import 'dart:async';
import 'dart:svg';

import 'package:angular2/angular2.dart';
import 'package:stream_transformers/stream_transformers.dart';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import '../../core/core.dart';

/** Exception thrown when attempting to load an icon with a name that cannot be found. */
class MdIconNameNotFoundError extends MdError {
  MdIconNameNotFoundError(String iconName)
      : super('Unable to find icon with the name "$iconName"');
}

/**
 * Exception thrown when attempting to load SVG content that does not contain the expected
 * <svg> tag.
 */
class MdIconSvgTagNotFoundError extends MdError {
  MdIconSvgTagNotFoundError() : super('<svg> tag not found');
}

/**
 * Configuration for an icon, including the URL and possibly the cached SVG element.
 */
class SvgIconConfig {
  SvgElement svgElement;
  String url;

  SvgIconConfig(this.url);
}

/** Returns the cache key to use for an icon namespace and name. */
String iconKey(String namespace, String name) => '$namespace:$name';

/**
 * Service to register and display icons used by the <md-icon> component.
 * - Registers icon URLs by namespace and name.
 * - Registers icon set URLs by namespace.
 * - Registers aliases for CSS classes, for use with icon fonts.
 * - Loads icons from URLs and extracts individual icons from icon sets.
 */
@Injectable()
class MdIconRegistry {
  /**
   * URLs and cached SVG elements for individual icons. Keys are of the format "[namespace]:icon".
   */
  Map<String, SvgIconConfig> _svgIconConfigs = <String, SvgIconConfig>{};

  /**
   * SvgIconConfig objects and cached SVG elements for icon sets, keyed by namespace.
   * Multiple icon sets can be registered under the same namespace.
   */
  Map<String, List<SvgIconConfig>> _iconSetConfigs =
      <String, List<SvgIconConfig>>{};

  /** Cache for icons loaded by direct URLs. */
  Map<String, SvgElement> _cachedIconsByUrl = <String, SvgElement>{};

  /** In-progress icon fetches. Used to coalesce multiple requests to the same URL. */
  Map<String, Stream<String>> _inProgressUrlFetches =
      <String, Stream<String>>{};

  /** Map from font identifiers to their CSS class names. Used for icon fonts. */
  Map<String, String> _fontCssClassesByAlias = <String, String>{};

  /**
   * The CSS class to apply when an <md-icon> component has no icon name, url, or font specified.
   * The default 'material-icons' value assumes that the material icon font has been loaded as
   * described at http://google.github.io/material-design-icons/#icon-font-for-the-web
   */
  String _defaultFontSetClass = 'material-icons';

  final _client = new BrowserClient();

  /** Registers an icon by URL in the default namespace. */
  MdIconRegistry addSvgIcon(String iconName, String url) {
    return addSvgIconInNamespace('', iconName, url);
  }

  /** Registers an icon by URL in the specified namespace. */
  MdIconRegistry addSvgIconInNamespace(
      String namespace, String iconName, String url) {
    final key = iconKey(namespace, iconName);
    _svgIconConfigs[key] = new SvgIconConfig(url);
    return this;
  }

  /** Registers an icon set by URL in the default namespace. */
  MdIconRegistry addSvgIconSet(String url) {
    return addSvgIconSetInNamespace('', url);
  }

  /** Registers an icon set by URL in the specified namespace. */
  MdIconRegistry addSvgIconSetInNamespace(String namespace, String url) {
    final config = new SvgIconConfig(url);
    if (_iconSetConfigs.containsKey(namespace)) {
      _iconSetConfigs[namespace].add(config);
    } else {
      _iconSetConfigs[namespace] = [config];
    }
    return this;
  }

  /**
   * Defines an alias for a CSS class name to be used for icon fonts. Creating an mdIcon
   * component with the alias as the fontSet input will cause the class name to be applied
   * to the <md-icon> element.
   */
  MdIconRegistry registerFontClassAlias(String alias, [String className]) {
    if (className == null) className = alias;
    _fontCssClassesByAlias[alias] = className;
    return this;
  }

  /**
   * Returns the CSS class name associated with the alias by a previous call to
   * registerFontClassAlias. If no CSS class has been associated, returns the alias unmodified.
   */
  String classNameForFontAlias(String alias) {
    return _fontCssClassesByAlias[alias] ?? alias;
  }

  /**
   * Sets the CSS class name to be used for icon fonts when an <md-icon> component does not
   * have a fontSet input value, and is not loading an icon by name or URL.
   */
  MdIconRegistry setDefaultFontSetClass(String className) {
    _defaultFontSetClass = className;
    return this;
  }

  /**
   * Returns the CSS class name to be used for icon fonts when an <md-icon> component does not
   * have a fontSet input value, and is not loading an icon by name or URL.
   */
  String get defaultFontSetClass => _defaultFontSetClass;

  /**
   * Returns an Observable that produces the icon (as an <svg> DOM element) from the given URL.
   * The response from the URL may be cached so this will not always cause an HTTP request, but
   * the produced element will always be a new copy of the originally fetched icon. (That is,
   * it will not contain any modifications made to elements previously returned).
   */
  Stream<SvgElement> getSvgIconFromUrl(String url) {
    if (_cachedIconsByUrl.containsKey(url)) {
      return new Stream.fromIterable([cloneSvg(_cachedIconsByUrl[url])]);
    }
    return _loadSvgIconFromConfig(new SvgIconConfig(url))
        .transform(
            new DoAction((SvgElement svg) => _cachedIconsByUrl[url] = svg))
        .map((SvgElement svg) => cloneSvg(svg));
  }

  /**
   * Returns an Observable that produces the icon (as an <svg> DOM element) with the given name
   * and namespace. The icon must have been previously registered with addIcon or addIconSet;
   * if not, the Observable will throw an MdIconNameNotFoundError.
   */
  Stream<SvgElement> getNamedSvgIcon(String name, [String namespace = '']) {
    // Return (copy of) cached icon if possible.
    final key = iconKey(namespace, name);
    if (_svgIconConfigs.containsKey(key)) {
      return _getSvgFromConfig(_svgIconConfigs[key]);
    }
    // See if we have any icon sets registered for the namespace.
    final List<SvgIconConfig> iconSetConfigs = _iconSetConfigs[namespace];
    if (iconSetConfigs != null && iconSetConfigs.isNotEmpty) {
      return _getSvgFromIconSetConfigs(name, iconSetConfigs);
    }
    throw new MdIconNameNotFoundError(key);
  }

  /**
   * Returns the cached icon for a SvgIconConfig if available, or fetches it from its URL if not.
   */
  Stream<SvgElement> _getSvgFromConfig(SvgIconConfig config) {
    if (config.svgElement != null) {
      // We already have the SVG element for this icon, return a copy.
      return new Stream.fromIterable([cloneSvg(config.svgElement)]);
    } else {
      // Fetch the icon from the config's URL, cache it, and return a copy.
      return _loadSvgIconFromConfig(config)
          .transform(new DoAction((SvgElement svg) => config.svgElement = svg))
          .map((SvgElement svg) => cloneSvg(svg));
    }
  }

  /**
   * Attempts to find an icon with the specified name in any of the SVG icon sets.
   * First searches the available cached icons for a nested element with a matching name, and
   * if found copies the element to a new <svg> element. If not found, fetches all icon sets
   * that have not been cached, and searches again after all fetches are completed.
   * The returned Observable produces the SVG element if possible, and throws
   * MdIconNameNotFoundError if no icon with the specified name can be found.
   */
  Stream<SvgElement> _getSvgFromIconSetConfigs(
      String name, List<SvgIconConfig> iconSetConfigs) {
    final namedIcon = _extractIconWithNameFromAnySet(name, iconSetConfigs);
    if (namedIcon != null) {
      // We could cache namedIcon in _svgIconConfigs, but since we have to make a copy every
      // time anyway, there's probably not much advantage compared to just always extracting
      // it from the icon set.
      return new Stream.fromIterable([namedIcon]);
    }
    // Not found in any cached icon sets. If there are icon sets with URLs that we haven't
    // fetched, fetch them now and look for iconName in the results.
    final Iterable<Stream<SvgElement>> iconSetFetchRequests = iconSetConfigs
        .where(
            (SvgIconConfig iconSetConfig) => iconSetConfig.svgElement == null)
        .map((SvgIconConfig iconSetConfig) {
      // TODO: Perhaps there is some bugs.
      Stream<SvgElement> svgIconSet;
      try {
        svgIconSet = _loadSvgIconSetFromConfig(iconSetConfig);
      } catch (error, strace) {
        print('Loading icon set URL: ${iconSetConfig.url} failed: $error');
        // TODO: new Stream.empty() instead?
        return new Stream.fromIterable([null]);
      }
      return svgIconSet.transform(new DoAction((SvgElement svg) {
        if (svg != null) iconSetConfig.svgElement = svg;
      }));
    });
    // Fetch all the icon set URLs. When the requests complete, every IconSet should have a
    // cached SVG element (unless the request failed), and we can check again for the icon.
    // TODO: Confirm it is the equivalent process of RxJS `forkJoin`.
    return Future
        .wait/*<SvgElement>*/(
            iconSetFetchRequests.map((Stream<SvgElement> v) => v.last))
        .then((_) {
      final foundIcon = _extractIconWithNameFromAnySet(name, iconSetConfigs);
      if (foundIcon == null) throw new MdIconNameNotFoundError(name);
      return foundIcon;
    }).asStream();
  }

  /**
   * Searches the cached SVG elements for the given icon sets for a nested icon element whose "id"
   * tag matches the specified name. If found, copies the nested element to a new SVG element and
   * returns it. Returns null if no matching element is found.
   */
  SvgElement _extractIconWithNameFromAnySet(
      String iconName, List<SvgIconConfig> iconSetConfigs) {
    // Iterate backwards, so icon sets added later have precedence.
    for (int i = iconSetConfigs.length - 1; i >= 0; i--) {
      final config = iconSetConfigs[i];
      if (config.svgElement != null) {
        final foundIcon =
            _extractSvgIconFromSet(config.svgElement, iconName, config);
        if (foundIcon != null) {
          return foundIcon;
        }
      }
    }
    return null;
  }

  /**
   * Loads the content of the icon URL specified in the SvgIconConfig and creates an SVG element
   * from it.
   */
  Stream<SvgElement> _loadSvgIconFromConfig(SvgIconConfig config) {
    return _fetchUrl(config.url).map(
        (String svgText) => _createSvgElementForSingleIcon(svgText, config));
  }

  /**
   * Loads the content of the icon set URL specified in the SvgIconConfig and creates an SVG element
   * from it.
   */
  Stream<SvgElement> _loadSvgIconSetFromConfig(SvgIconConfig config) {
    // TODO: Document that icons should only be loaded from trusted sources.
    return _fetchUrl(config.url)
        .map((svgText) => _svgElementFromString(svgText));
  }

  /**
   * Creates a DOM element from the given SVG string, and adds default attributes.
   */
  SvgElement _createSvgElementForSingleIcon(
      String responseText, SvgIconConfig config) {
    final svg = _svgElementFromString(responseText);
    _setSvgAttributes(svg, config);
    return svg;
  }

  /**
   * Searches the cached element of the given SvgIconConfig for a nested icon element whose "id"
   * tag matches the specified name. If found, copies the nested element to a new SVG element and
   * returns it. Returns null if no matching element is found.
   */
  SvgElement _extractSvgIconFromSet(
      SvgElement iconSet, String iconName, SvgIconConfig config) {
    final Element iconNode = iconSet.querySelector('#$iconName');
    if (iconNode == null) {
      return null;
    }
    // If the icon node is itself an <svg> node, clone and return it directly. If not, set it as
    // the content of a new <svg> node.
    if (iconNode.tagName.toLowerCase() == 'svg') {
      return _setSvgAttributes(iconNode.clone(true) as SvgElement, config);
    }
    // createElement('SVG') doesn't work as expected; the DOM ends up with
    // the correct nodes, but the SVG content doesn't render. Instead we
    // have to create an empty SVG node using innerHTML and append its content.
    // Elements created using DOMParser.parseFromString have the same problem.
    // http://stackoverflow.com/questions/23003278/svg-innerhtml-in-firefox-can-not-display
    final svg = _svgElementFromString('<svg></svg>');
    // Clone the node so we don't remove it from the parent icon set element.
    svg.append(iconNode.clone(true));
    return _setSvgAttributes(svg, config);
  }

  /**
   * Creates a DOM element from the given SVG string.
   */
  SvgElement _svgElementFromString(String str) {
    final div = new DivElement()
      ..setInnerHtml(str, validator: new NodeValidatorBuilder()..allowSvg());
    final SvgElement svg = div.querySelector('svg') as SvgElement;
    if (svg == null) {
      throw new MdIconSvgTagNotFoundError();
    }
    return svg;
  }

  /**
   * Sets the default attributes for an SVG element to be used as an icon.
   */
  SvgElement _setSvgAttributes(SvgElement svg, SvgIconConfig config) {
    if (svg.attributes['xmlns'] == null) {
      svg.attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    }
    return svg
      ..setAttribute('fit', '')
      ..setAttribute('height', '100%')
      ..setAttribute('width', '100%')
      ..setAttribute('preserveAspectRatio', 'xMidYMid meet')
      ..setAttribute('focusable',
          'false'); // Disable IE11 default behavior to make SVGs focusable.
  }

  /**
   * Returns an Stream which produces the string contents of the given URL. Results may be
   * cached, so future calls with the same URL may not cause another HTTP request.
   */
  Stream<String> _fetchUrl(String url) {
    // Store in-progress fetches to avoid sending a duplicate request for a URL when there is
    // already a request in progress for that URL. It's necessary to call share() on the
    // Observable returned by http.get() so that multiple subscribers don't cause multiple XHRs.
    if (_inProgressUrlFetches.containsKey(url)) {
      return _inProgressUrlFetches[url];
    }
    // Dart version's note.
    // There might be more appropriate architecture to avoid broadcastStream
    // But I guess it's most convenient solution not to get far off original RxJS's `share`.
    final Stream<String> request = _client
        .get(url)
        .asStream()
        .asBroadcastStream()
        .map((http.Response response) => response.body)
        .transform(new DoAction((_) {
      if (_inProgressUrlFetches.containsKey(url)) {
        _inProgressUrlFetches.remove(url);
      }
    }));
    _inProgressUrlFetches[url] = request;
    return request;
  }
}

/** Clones an SVGElement while preserving type information. */
SvgElement cloneSvg(SvgElement svg) => svg.clone(true) as SvgElement;
