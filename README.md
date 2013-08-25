Barista
=======

Barista is a modular web server written in Objective-C. Its purpose is to allow embedding a web server into another app or developer tool. Barista takes inspiration from node.js and the [ExpressJS](http://expressjs.com/) web server, breaking its system up into smaller pieces that can be connected together.

Status
======

Barista is currently early in development. It probably should not be used in an app you're shipping to end users just yet. But it is likely more than adequate for internal tools or building development tools.

The API is not stable, and could or will break for any reason.

Usage/Middleware
================

At its most basic, a Barista server is just an HTTP server (running on an arbitrary port). It doesn't do anything by default. In order to actually handle requests, you need to add components to the server. Barista includes several components you might (or might not) want to add to your stack. These include:

- a URL router
- cookies and sessions
- support for gzipping responses
- parsing request and response bodies (only JSON is supported right now)
- serving static files from a directory, with automatic ETag/If-None-Match support
- rendering templates (only [Mustache](https://github.com/groue/GRMustache) is supported right now)

To add these components, Barista uses the concept of middleware to build a processing pipeline for each request. Barista exposes a `BaristaMiddleware` protocol that allows you intercept a request either (or both) before and after a request. The order you add middleware determines the order they run. They typically should terminate in a `BARRouter`. Once you add the `BARRouter` based on [JLRoutes](https://github.com/joeldev/JLRoutes), you can handle as many different types of URLs as you like in a few lines of code.

```objective-c
	[self addRoute:@"/foo/:bar" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		NSString *responseMessage = [NSString stringWithFormat:@"Hello, %@", parameters[@"bar"]]; // parameters[@"bar"] maps to the key/value set in the URL, e.g. @"42" /foo/42

		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		response.body = [responseMessage dataUsingEncoding:NSUTF8StringEncoding];
		[connection sendResponse:response];
		return YES;
	}];
```

Middleware are inherently chainable. If you add a `BARCookieParser` and a `BARSessionStore` before your `BARRouter`, a request pipeline would look like this:

- an incoming request comes in
- `BARCookieParser` parses the cookies in the request, if any, and adds that data to the request
- `BARSessionStore` examines the cookie objects attached to the request, if any, and adds the corresponding session to the request, if it exists
- your routed method, which now has access to both the cookies and the session, handles the request, and returns a response
- `BARSessionStore` adds the cookie object to the response
- `BARCookieParser` serializes the cookie object into a header and attaches it to the response
- the response is serialized out and returned to the client

You'll notice that middleware can extend request and response objects with their own methods and data. In the request of the above example, `BARCookieParser` converts headers into `NSHTTPCookie` objects, and attaches those to the request. `BARSessionStore` looks for `NSHTTPCookie` objects and uses them to look up or create `BARSession` objects, which get attached to the request. Then, your route has the ability to look for either the `NSHTTPCookie` objects or the `BARSession` object and act accordingly. Similarly, in the response, the `BARSessionStore` adds the cookies for the `BARSession` to the response, and the `BARCookieParser` converts the cookies on the response to HTTP headers.

Middleware can also intercept requests and handle them automatically if appropriate, preventing the actual route method from being called. This is useful if, for example, you want to prevent users from accessing resources if they are not logged in. If you implemented a piece of middleware that acted as an authorization gate, and added it to the above middleware chain, it would work something like this:

- If the user is logged in:
 - an incoming request comes in
 - `BARCookieParser` parses the cookies in the request, if any, and adds that data to the request
 - `BARSessionStore` examines the cookie objects attached to the request, if any, and adds the corresponding session to the request, if it exists
 - your authorization gate would detect they are authorized and would continue, perhaps adding user metadata to the session
 - your routed method, which now has access to both the cookies and the session, handles the request, and returns a response
 - your authorization gate doesn't need to do anything to the response, so it continues automatically
 - `BARSessionStore` adds the cookie object to the response
 - `BARCookieParser` serializes the cookie object into a header and attaches it to the response
 - the response is serialized out and returned to the client
- If the user is NOT logged in:
 - an incoming request comes in
 - `BARCookieParser` parses the cookies in the request, if any, and adds that data to the request
 - `BARSessionStore` examines the cookie objects attached to the request, if any, and adds the corresponding session to the request, if it exists
 - your authorization gate would detect they are **not** authorized, and would send a `403 Forbidden` or `401 Unauthorized` response
 - your authorization gate doesn't need to do anything to the response, so it continues automatically
 - `BARSessionStore` adds the cookie object to the response
 - `BARCookieParser` serializes the cookie object into a header and attaches it to the response
 - the response is serialized out and returned to the client

In the second outcome, note that the routed method is never called. This is because middleware has the ability to intercept requests, send their own responses, and prevent them from continuing to the next step in the chain. This makes it very easy and flexible to isolate application logic from basic processing.

Templating
==========

Barista has middleware support for templating engines, specifically Mustache with [GRMustache](https://github.com/groue/GRMustache). If you are rendering web pages, this means you can move that data out of your Objective-C code and into files which get rendered at runtime. Templates can be passed an object with values to include, as well. To do this, add the `BARMustacheTemplateRenderer` middleware to your chain, and point it at a directory of template files. Here is an example of how to do templating in Barista:

In Objective-C:

```objective-c
	[self addRoute:@"/hello" forHTTPMethod:@"GET" handler:^BOOL(BARConnection *connection, BARRequest *request, NSDictionary *parameters) {
		BARResponse *response = [[BARResponse alloc] init];
		response.statusCode = 200;
		[response setViewToRender:@"hello" withObject:@{@"title": @"Hello world!"}];
		[connection sendResponse:response];
		return YES;
	}];
```

In `hello.mustache`:

```html
<!DOCTYPE html>
<html>
<head>
	<title>{{title}}</title>
</head>
<body>
	<div>{{title}}</div>
</body>
</html>
```

The resulting HTML:
```html
<!DOCTYPE html>
<html>
<head>
	<title>Hello world!</title>
</head>
<body>
	<div>Hello world!</div>
</body>
</html>
```

You can combine this with a `BARStaticFileServer` to include images, JavaScript, CSS, and whatever else to build rich web pages and web applications.

Wish List
=========

- Better error handling
- Unit tests
- Add middleware support for individual routes in the router
- Automatic resource mapping to Core Data
- SCSS/SASS/LESS/CoffeeScript/whatever compilation
- Authorization middleware (<s>Basic auth</s>, Digest auth, OAuth 1.0, OAuth 2, etc.)
- Persistent session stores
- XPC support on Mac

If you wish to contribute middleware or other changes, please submit a pull request. If you are adding new middleware, add an subspec entry to the podspec in the appropriate place. And add your name to the contributors list below, along with adding acknowledgements for open source code.

Contributors
============

- [Steve Streza](https://twitter.com/SteveStreza)
- [Grant Butler](https://twitter.com/grantjbutler)
- [Bill Williams](https://twitter.com/asmallteapot)

Acknowledgements
================

- [NSData+Base64](http://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html) by [Matt Gallagher](http://www.cocoawithlove.com/) for Base64 support
- [NSDataCategory](http://www.cocoadev.com/index.pl?NSDataCategory)

License
=======

See the LICENSE.md file.
