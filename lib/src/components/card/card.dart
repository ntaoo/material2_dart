import 'package:angular2/angular2.dart';

/// Content of a card, needed as it's used as a selector in the API.
@Directive(selector: 'md-card-content')
class MdCardContent {}

/// Title of a card, needed as it's used as a selector in the API.
@Directive(selector: 'md-card-title')
class MdCardTitle {}

/// Sub-title of a card, needed as it's used as a selector in the API.
@Directive(selector: 'md-card-subtitle')
class MdCardSubtitle {}

/// Action section of a card, needed as it's used as a selector in the API.
@Directive(selector: 'md-card-actions')
class MdCardActions {}

/// Footer of a card, needed as it's used as a selector in the API.
@Directive(selector: 'md-card-footer')
class MdCardFooter {}

/*
<md-card> is a basic content container component that adds the styles of a material design card.

While you can use this component alone,
it also provides a number of preset styles for common card sections, including:
 - md-card-title
 - md-card-subtitle
 - md-card-content
 - md-card-actions
 - md-card-footer

 You can see some examples of cards here:
 http://embed.plnkr.co/s5O4YcyvbLhIApSrIhtj/

 TODO(kara): update link to demo site when it exists
*/
@Component(
    selector: 'md-card',
    templateUrl: 'card.html',
    styleUrls: const ['card.scss.css'],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdCard {}

/*  The following components don't have any behavior.
 They simply use content projection to wrap user content
 for flex layout purposes in <md-card> (and thus allow a cleaner, boilerplate-free API).


<md-card-header> is a component intended to be used within the <md-card> component.
It adds styles for a preset header section (i.e. a title, subtitle, and avatar layout).

You can see an example of a card with a header here:
http://embed.plnkr.co/tvJl19z3gZTQd6WmwkIa/

TODO(kara): update link to demo site when it exists
*/
@Component(
    selector: 'md-card-header',
    templateUrl: 'card_header.html',
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdCardHeader {}

/*
<md-card-title-group> is a component intended to be used within the <md-card> component.
It adds styles for a preset layout that groups an image with a title section.

You can see an example of a card with a title-group section here:
http://embed.plnkr.co/EDfgCF9eKcXjini1WODm/

TODO(kara): update link to demo site when it exists
*/

@Component(
    selector: 'md-card-title-group',
    templateUrl: 'card_title_group.html',
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdCardTitleGroup {}

const List MD_CARD_DIRECTIVES = const [
  MdCard,
  MdCardContent,
  MdCardHeader,
  MdCardTitleGroup,
  MdCardTitle,
  MdCardSubtitle,
  MdCardActions
];
