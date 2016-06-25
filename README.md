# Material Design for Angular 2

[![Join the chat at https://gitter.im/ntaoo/material2_dart](https://badges.gitter.im/ntaoo/material2_dart.svg)](https://gitter.im/ntaoo/material2_dart?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

It is [angular/material2](https://github.com/angular/material2) for Dart.

[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg?maxAge=2592000)](https://gitter.im/ntaoo/material2_dart)

## Why

The [angular/material2](https://github.com/angular/material2) is one of the prospective standard material design UI library for angular2 TypeScript / JavaScript users. Bringing it into native Dart package will be useful.

Another high-quality angular2 Dart material design UI library is expected to be published soon (coming July?) as stated in the angular/material2 issue tracker. I believe most Dart people will choose it, and it is absolutely fine with me.

I have been maintaining the same API and internal structure as much as I can for easy side by side comparison between the Dart version and the TypeScript version. (And for easy updating.) It would clarify the API compatibility, and hopefully, it would be a good code example for TypeScript / JavaScript users who are interested in angular2 Dart version.

## Project Status

#### Current porting target.

497a3c1(commit SHA1) 6/15/2016: **DONE**.

#### Notes

This package is very much a work in progress.

Please note that the original [angular/material2](https://github.com/angular/material2) is in alpha phase, and this package may contain additional bugs.

**I would change the package name on the next update of Angular2 Dart and the next release of angular/material2. (At leaset one month later.)**

### Components

All porting works have done for the current target.

* [Button](https://github.com/ntaoo/material2_dart/tree/master/lib/components/button)
* [Button Toggle](https://github.com/ntaoo/material2_dart/tree/master/lib/components/button_toggle) (This is not working. I will investigate it after the next ng2 Dart update.)
* [Card](https://github.com/ntaoo/material2_dart/tree/master/lib/components/card)
* [Checkbox](https://github.com/ntaoo/material2_dart/tree/master/lib/components/checkbox)(Without enough test code)
* [Grid List](https://github.com/ntaoo/material2_dart/tree/master/lib/components/grid_list)(Without enough test code)
* [Icon](https://github.com/ntaoo/material2_dart/tree/master/lib/components/icon)
* [Input](https://github.com/ntaoo/material2_dart/tree/master/lib/components/input)(Without enough test code)
* [List](https://github.com/ntaoo/material2_dart/tree/master/lib/components/list)
* [Progress Bar](https://github.com/ntaoo/material2_dart/tree/master/lib/components/progress_bar)(Without enough test code)
* [Progress Circle](https://github.com/ntaoo/material2_dart/tree/master/lib/components/progress_circle)(Without enough test code)
* [Radio](https://github.com/ntaoo/material2_dart/tree/master/lib/components/radio)(Without enough test code)
* [Sidenav](https://github.com/ntaoo/material2_dart/tree/master/lib/components/sidenav)
* [Slide Toggle](https://github.com/ntaoo/material2_dart/tree/master/lib/components/slide_toggle)(Without enough test code)
* [Tabs](https://github.com/ntaoo/material2_dart/tree/master/lib/components/tabs) (The `async tabs` is broken. See [issues/30](https://github.com/ntaoo/material2_dart/issues/30))
* [Toolbar](https://github.com/ntaoo/material2_dart/tree/master/lib/components/tabs)

### Core

All porting works have done for the current target.

Gestures are not ported. It looks like Angular2 Dart does not support gestures as of beta-17. I will investigate it after next Angular2 Dart release.

## Prerequisites

This package depends on [scissors package](https://github.com/google/dart-scissors) which requires to install `sassc` for scss compilation. (Ruby sass is not supported.)

If you have not set up scissors, please set up `scissors` with the [guide](https://github.com/google/dart-scissors#prerequisites).

## Usage

1. Add this to your package's pubspec.yaml file. [(The example)](https://github.com/ntaoo/material2_dart/blob/master/example/pubspec.yaml)

        dependencies:
          material2_dart: any

2. Run `pub get`.

3. Import component files and add directives on a component metadata. [(The example)](https://github.com/ntaoo/material2_dart/tree/master/example/lib/button)

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

5. Go to `http://localhost:8080` on a browser. (I recommend Dartium because perhaps there are still browser-specific bugs on this package.)


## Contributing

Your contribution is welcome. Please note that this project is nothing more than a porting work of [angular/material2](https://github.com/angular/material2).

Many tests have not been ported, so it is much appreciated if you help to port them.

### Features and bugs

Basically, I would not add any original features on it. If you need new features, please consider contributing [angular/material2](https://github.com/angular/material2).

If you find this Dart version's specific bugs, please file them at the [issue tracker][tracker].

[tracker]: https://github.com/ntaoo/material2_dart/issues

### Testing Angular2.

#### Run test server on the project root.

    pub serve

#### Run tests on dartium.

    pub run test --pub-serve=8080 -p dartium
