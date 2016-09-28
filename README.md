This is the Dart version of [angular/material2](https://github.com/angular/material2) being ported by individual.

[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg?maxAge=2592000)](https://gitter.im/ntaoo/material2_dart)

## Project Status

Synced with the 2.0.0-alpha.9 except gesture support and non 'available' components. 

## Prerequisites

This package depends on [scissors package](https://github.com/google/dart-scissors) which requires to install `sassc` for scss compilation. (Ruby sass is not supported.)
If you have not set up scissors, please set up `scissors` with the [guide](https://github.com/google/dart-scissors#prerequisites).

### Components

* [Button](https://github.com/ntaoo/material2_dart/tree/master/doc/components/button.md)
* [Button Toggle](https://github.com/ntaoo/material2_dart/tree/master/doc/components/button_toggle.md) 
* [Card](https://github.com/ntaoo/material2_dart/tree/master/doc/components/card.md)
* [Checkbox](https://github.com/ntaoo/material2_dart/tree/master/doc/components/checkbox.md)
* [Grid List](https://github.com/ntaoo/material2_dart/tree/master/doc/components/grid_list.md)
* [Icon](https://github.com/ntaoo/material2_dart/tree/master/doc/components/icon.md)
* [Input](https://github.com/ntaoo/material2_dart/tree/master/doc/components/input.md)
* [List](https://github.com/ntaoo/material2_dart/tree/master/doc/components/list.md)
* [Progress Bar](https://github.com/ntaoo/material2_dart/tree/master/doc/components/progress_bar.md)
* [Progress Circle](https://github.com/ntaoo/material2_dart/tree/master/doc/components/progress_circle.md)
* [Radio](https://github.com/ntaoo/material2_dart/tree/master/doc/components/radio.md)
* [Sidenav](https://github.com/ntaoo/material2_dart/tree/master/doc/components/sidenav.md)
* [Slider](https://github.com/ntaoo/material2_dart/tree/master/doc/components/slider.md)
* [Slide Toggle](https://github.com/ntaoo/material2_dart/tree/master/doc/components/slide_toggle.md)
* [Tabs](https://github.com/ntaoo/material2_dart/tree/master/doc/components/tabs.md)
* [Toolbar](https://github.com/ntaoo/material2_dart/tree/master/doc/components/tabs.md)

## Usage

1. Add this to your package's pubspec.yaml file. [(The example)](https://github.com/ntaoo/material2_dart/blob/master/example/pubspec.yaml)

        dependencies:
          material2_dart: any

2. Run `pub get`.

3. Import this library as `import 'package:material2_dart:material.dart'`. [(The example)](https://github.com/ntaoo/material2_dart/tree/master/example/lib/button)

## Example

Please see the [Demo App](https://github.com/ntaoo/material2_dart/tree/master/example/) which includes all of the components and core functions usages.

### How to see the Demo App on a browser.

[Assuming you have already installed Dart](https://www.dartlang.org/downloads/),

1. Clone this repository.

        git clone https://github.com/ntaoo/material2_dart.git

2. Go to the example directory.

        cd material2_dart/example

3. Run `pub get` to get all the dependent packages.

        pub get

4. Run `pub serve` to start up a development server.

        pub serve

5. Go to `http://localhost:8080` on a browser.


## Contributing

Your contribution is welcome. Please note that this project is nothing more than a porting work of [angular/material2](https://github.com/angular/material2).

Many tests have not been ported, so it is much appreciated if you help to port them.

### Features and bugs

I would not add any original features on it. If you need some new features, please consider contributing [angular/material2](https://github.com/angular/material2).

If you find this Dart version's specific bugs, please file them at the [issue tracker][tracker].

[tracker]: https://github.com/ntaoo/material2_dart/issues


### Testing material2_dart.

#### Run test server on the project root.

    pub serve

#### Run tests on dartium.

    pub run test --pub-serve=8080 -p dartium
