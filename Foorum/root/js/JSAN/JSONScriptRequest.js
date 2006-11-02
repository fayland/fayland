// This specification does not include the following features that may or may not be implemented by user agents:
//
//     * load event and onload attribute;
//     * error event and onerror attribute;
//     * progress event and onprogress attribute;
//     * abort event and onabort attribute;
//     * Timers have been suggested, perhaps an ontimeout attribute;
//     * Property to disable following redirects;
//     * responseXML for text/html documents;
//     * Cross-site XMLHttpRequest.
//
// HTTP requests sent from multiple different XMLHttpRequest objects in succession should be pipelined into shared HTTP connections.
//
// readystatechange
// The readystatechange event must be dispatched when readyState changes value.
// It must not bubble, must not be cancelable and must implement the Event interface [DOM3Events].
// The event has no namespace (Event.namespaceURI is null).

function JSONScriptRequest(args) {
    this._initialize_all();

    if (typeof args != 'undefined') {
        if (typeof args['callback_param'] != 'undefined') {
            this._callback_param = args['callback_param'];
        }
    }
};

JSONScriptRequest.VERSION = 0.02;

JSONScriptRequest._extends = function(base, thisConstructor, thisPrototype) {
    if (typeof thisPrototype == 'undefined' || thisPrototype == null) {
        thisPrototype = {};
    }

    // modify base class
    if (base.prototype.constructor == Object.prototype.constructor) {
        base.prototype.constructor = base;
    }

    // create prototype
    var Prototype = function() {};
    Prototype.prototype = base.prototype;

    // create class
    thisConstructor.prototype = new Prototype();

    for (var property in thisPrototype) {
        thisConstructor.prototype[property] = thisPrototype[property];
    }
    var dontEnums = ['constructor',
                     'hasOwnProperty',
                     'isPrototypeOf',
                     'toLocaleString',
                     'toString',
                     'valueOf'];
    for (var i = 0; i < dontEnums.length; i++) {
        var property = dontEnums[i];
        if (thisPrototype.hasOwnProperty(property)) {
            thisConstructor.prototype[property] = thisPrototype[property];
        }
    }
    thisConstructor.prototype.constructor = thisConstructor;
    thisConstructor.prototype.base = base;

    return thisConstructor;
};

JSONScriptRequest._Exception = JSONScriptRequest._extends
(Object,
 function(name, message) {
     this.name = name;
     this.message = message;
 },
 {
     toString: function() {
         return this.name + ': ' + this.message + ' [JSONScriptRequest]';
     }
 });

JSONScriptRequest.SYNTAX_ERR = JSONScriptRequest._extends
(JSONScriptRequest._Exception,
 function(message) {
     this.base('SYNTAX_ERR', message);
 });

JSONScriptRequest.SECURITY_ERR = JSONScriptRequest._extends
(JSONScriptRequest._Exception,
 function(message) {
     this.base('SECURITY_ERR', message);
 });

JSONScriptRequest.INVALID_STATE_ERR = JSONScriptRequest._extends
(JSONScriptRequest._Exception,
 function(message) {
     this.base('INVALID_STATE_ERR', message);
 });


JSONScriptRequest._RE = {
        'method': /^(?:OPTIONS|GET|HEAD|POST|PUT|DELETE|TRACE|CONNECT|[\x21\x23-\x27\x2A\x2B\x2D\x2E\x30-\x39\x41-\x5A\x5E-\x7A\x7C\x7E]+)$/,
        'field-name': /^[\x21\x23-\x27\x2A\x2B\x2D\x2E\x30-\x39\x41-\x5A\x5E-\x7A\x7C\x7E]+$/,
        'http_URL-custom': /^.+$/,
        'userinfo': /^([A-Za-z0-9\-\._~]|%[0-9A-F][0-9A-F]|[!$&\x27\(\)\*\+,;=]|:)*$/,
        'username-value': /^\x22(?:[\x20\x21\x23-\x7E\x80-\xFF]|(?:\x0D\x0A)?[\x20\x09]+|\\[\x00-\x7F])*\x22$/,
        'username-value-custom': /^(?:[\x20\x21\x23-\x7E\x80-\xFF]|(?:\x0D\x0A)?[\x20\x09]+|\\[\x00-\x7F])*$/,
        'field-value': /^(?:(?:(?:[\x20\x21\x23-\x7E\x80-\xFF]|(?:\x0D\x0A)?[\x20\x09]+)*|(?:[\x21\x23-\x27\x2A\x2B\x2D\x2E\x30-\x39\x41-\x5A\x5E-\x7A\x7C\x7E]+|[\x22\x28\x29\x2C\x2F\x3A-\x40\x5B-\x5D\x7B\x7D]| (?:\x22(?:[\x20\x21\x23-\x7E\x80-\xFF]|(?:\x0D\x0A)?[\x20\x09]+|\\[\x00-\x7F])*\x22))*)|(?:\x0D\x0A)?[\x20\x09]+)*$/
};

JSONScriptRequest._toSourceHelper = function(target) {
    if (typeof target == 'undefined') {
        return 'undefined';
    } else if (target == null) {
        return 'null';
    } else if (target.constructor == String) {
        return '"' + target + '"';
    } else if (target.constructor == Number) {
        return target;
    } else if (target.constructor == Array) {
        var r = [];
        for(var i = 0, n = target.length; i < n; i++) {
            r.push(JSONScriptRequest._toSourceHelper(target[i]));
        }
        return '[' + r.join(', ') + ']';
    } else if (target.constructor == Object) {
        var r = [];
        for(var i in target) {
            r.push(i + ':' + JSONScriptRequest._toSourceHelper(target[i]));
        }
        return '{' + r.join(', ') + '}';
    }
};

JSONScriptRequest._toSource = function(target) {
    if (target && target.constructor == Object) {
        return '(' + JSONScriptRequest._toSourceHelper(target) + ')';
    } else {
        return JSONScriptRequest._toSourceHelper(target);
    }
};

JSONScriptRequest._dispatchers = [];

JSONScriptRequest.prototype = {

    // TODO: Objects implementing the XMLHttpRequest interface must also implement the EventTarget interface [DOM3Events].
    //       http://www.w3.org/TR/DOM-Level-3-Events/events.html#Events-EventTarget
    addEventListener: function() {
        throw new JSONScriptRequest.SYNTAX_ERR('addEventListener is not implemented');
        return;
    },

    removeEventListener: function() {
        throw new JSONScriptRequest.SYNTAX_ERR('removeEventListener is not implemented');
        return;
    },

    dispatchEvent: function() {
        throw new JSONScriptRequest.SYNTAX_ERR('dispatchEvent is not implemented');
        return false;
    },

    addEventListenerNS: function() {
        throw new JSONScriptRequest.SYNTAX_ERR('addEventListenerNS is not implemented');
        return;
    },

    removeEventListenerNS: function() {
        throw new JSONScriptRequest.SYNTAX_ERR('removeEventListenerNS is not implemented');
        return;
    },

    open: function(method, url, async, user, password) {
        // If open() is invoked when readyState is 4 (Loaded) all members of the object must be set to their initial values.
        if (this.readyState == 4) {
            this._initialize_all();
        }

        // If the method argument doesn't match the method production defined in section 5.1.1 of [RFC2616] a SYNTAX_ERR  must be raised by the user agent.
        if (   typeof method == 'undefined'
            || method == null
            || !method.match(JSONScriptRequest._RE['method'])
            )
        {
            throw new JSONScriptRequest.SYNTAX_ERR('method: ' + method);
        }

        var METHOD = method.toUpperCase();
        // TODO: If the user agent doesn't support the given method for security reasons a SECURITY_ERR should be raised.
        ;

        // User agents must at least support the following list of methods (see [RFC2616], [RFC2518], [RFC3253], [RFC3648] and [RFC3744])
        if (METHOD != 'GET' && (   METHOD == 'POST'
                                || METHOD == 'HEAD'
                                || METHOD == 'PUT'
                                || METHOD == 'DELETE'
                                || METHOD == 'PROPFIND'
                                || METHOD == 'PROPPATCH'
                                || METHOD == 'MKCOL'
                                || METHOD == 'COPY'
                                || METHOD == 'MOVE'
                                || METHOD == 'LOCK'
                                || METHOD == 'UNLOCK'
                                || METHOD == 'VERSION-CONTROL'
                                || METHOD == 'REPORT'
                                || METHOD == 'CHECKOUT'
                                || METHOD == 'CHECKIN'
                                || METHOD == 'UNCHECKOUT'
                                || METHOD == 'MKWORKSPACE'
                                || METHOD == 'UPDATE'
                                || METHOD == 'LABEL'
                                || METHOD == 'MERGE'
                                || METHOD == 'BASELINE-CONTROL'
                                || METHOD == 'MKACTIVITY'
                                || METHOD == 'ORDERPATCH'
                                || METHOD == 'ACL'
                                )
            )
        {
            throw new JSONScriptRequest.SYNTAX_ERR(method + ' is not supported');
        }

        // User agents should support any method argument that matches the method production.
        if (METHOD != 'GET'/* JSONScriptRequest can only GET request*/) {
            throw new JSONScriptRequest.SYNTAX_ERR(method + ' is not supported');
        }

        // When method case-insensitively matches GET, POST, HEAD, PUT or DELETE the user agent must use the uppercase equivalent instead.
        if (   METHOD == 'GET'
            || METHOD == 'POST'
            || METHOD == 'HEAD'
            || METHOD == 'PUT'
            || METHOD == 'DELETE'
            )
        {
            method = METHOD;
        }

        // TODO: If the url parameter doesn't match the syntax defined in section 3.2.2 of [RFC2616] a SYNTAX_ERR must be raised.
        if (   typeof url == 'undefined'
            || url == null
            || !url.match(JSONScriptRequest._RE['http_URL-custom'])
            )
        {
            throw new JSONScriptRequest.SYNTAX_ERR('url: ' + url);
        }

        // When a non same-origin url argument is given user agents should throw a SECURITY_ERR exception.
        // Note: A future version or extension of this specification will define a way of doing cross-site requests.
        if (0 /* JSONScriptRequest can deal with cross-site request */) {
            throw new JSONScriptRequest.SECURITY_ERR('url: ' + url + ' is cross-site');
        }

        // TODO: User agents should not support the "user:password" format in the userinfo production defined in section 3.2.1 of [RFC3986] and must throw a SYNTAX_ERR when doing so (not supporting it).
        if (url.match(new RegExp('^[^:]+://([^@]*)@[^/]+'))) {
            throw new JSONScriptRequest.SYNTAX_ERR(RegExp.$1 + ' is not supported');
            var userinfo = RegExp.$1;
            if (!userinfo.match(JSONScriptRequest._RE['userinfo'])) {
                throw new JSONScriptRequest.SYNTAX_ERR('userinfo: ' + userinfo);
            }
            userinfo = (userinfo.indexOf(':') != -1) ? userinfo.split(/:/) : [userinfo];
            if (2 < userinfo.length) {
                throw new JSONScriptRequest.SYNTAX_ERR('userinfo: ' + userinfo);
            }
            // When they do support it, or in case of people using the format "user", user agents must use them if the user and password arguments are omitted. If the arguments are not omitted, they take precedence, even if they are null.
            if (typeof user == 'undefined') {
                user = userinfo[0];
            }
            if (typeof password == 'undefined') {
                password = userinfo[1];
            }
        }

        // If the user argument doesn't match the username-value production defined in section 3.2.2 of [RFC2617] user agents must throw a SYNTAX_ERR exception.
        if (   user != null
            && typeof user != 'undefined'
            && !user.match(JSONScriptRequest._RE['username-value-custom'])
            )
        {
            throw new JSONScriptRequest.SYNTAX_ERR('user: ' + user);
        }

        // must initialize the object by remembering
        this._method   = method;
        this._url      = url;
        this._async    = typeof async    == 'undefined' ? true : async;    // defaulting to true if omitted
        this._user     = typeof user     == 'undefined' ? null : user;     // defaulting to null if omitted
        this._password = typeof password == 'undefined' ? null : password; // defaulting to null if omitted

        // resetting the responseText, responseXML, status, and statusText attributes to their initial values
        this.responseText = null;
        this.responseXML = null;
        this.status = 0;
        this.statusText = '';

        // resetting the list of request headers
        this._requestHeaders = {};

        // setting the readyState attribute to 1 (Open)
        this._readystatechange(1);

        return;
    },

    setRequestHeader: function(header, value) {
        // If the readyState  attribute has a value other than 1 (Open), an INVALID_STATE_ERR exception must be raised;
        if (this.readyState != 1) {
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 1');
        }
        // If the header argument doesn't match the field-name production as defined by section 4.2 of [RFC2616] a SYNTAX_ERR must be raised;
        if (   typeof header == 'undefined'
            || header == null
            || !header.match(JSONScriptRequest._RE['field-name'])
            )
        {
            throw new JSONScriptRequest.SYNTAX_ERR('header: ' + header);
        }
        // If the value argument doesn't match the field-value production as defined by section 4.2 of [RFC2616] a SYNTAX_ERR must be raised;
        if (!value.match(JSONScriptRequest._RE['field-value'])) {
            throw new JSONScriptRequest.SYNTAX_ERR('value: ' + value);
        }

        // For security reasons nothing should be done if the header argument matches Accept-Charset, Accept-Encoding, Content-Length, Expect, Date, Host, Keep-Alive, Referer, TE, Trailer, Transfer-Encoding or Upgrade case-insensitively.
        if (header.match(new RegExp('Accept-Charset|Accept-Encoding|Content-Length|Expect|Date|Host|Keep-Alive|Referer|TE|Trailer|Transfer-Encoding|Upgrade', 'i'))) {
            return;
        }

        // Implementations must replace any existing value if the nominated request header field value is one of: Authorization, Content-Base, Content-Location, Content-MD5, Content-Range, Content-Type, Content-Version, Delta-Base, Depth, Destination, ETag, Expect, From, If-Modified-Since, If-Range, If-Unmodified-Since, Max-Forwards, MIME-Version, Overwrite, Proxy-Authorization, SOAPAction or Timeout.
        if (header.match(new RegExp('Authorization|Content-Base|Content-Location|Content-MD5|Content-Range|Content-Type|Content-Version|Delta-Base|Depth|Destination|ETag|Expect|From|If-Modified-Since|If-Range|If-Unmodified-Since|Max-Forwards|MIME-Version|Overwrite|Proxy-Authorization|SOAPAction|Timeout', 'i')))
        {
            this._requestHeaders[header] = value;
        }
        else {
            // Otherwise, if the nominated request header field already has a value, the new value must be combined with the existing value (section 4.2, [RFC2616]).
            if (header in this._requestHeaders) {
                if (typeof this._requestHeaders[header] == 'string') {
                    var existing = this._requestHeaders[header];
                    this._requestHeaders[header] = [];
                    this._requestHeaders[header].push(existing);
                    this._requestHeaders[header].push(value);
                } else {
                    this._requestHeaders[header].push(value);
                }
            } else {
                this._requestHeaders[header] = value;
            }
        }

        return;
    },

    send: function(data) {
        // If the readyState attribute has a value other than 1 (Open), an INVALID_STATE_ERR  exception must be raised.
        if (this.readyState != 1) {
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 1');
        }

        // url, if relative, must be resolved using window.document.baseURI of the window whose constructor is used.
        var url = this._url;
        if (url.indexOf('http://') == -1) {
            if (   typeof window.document.baseURI != 'undefined'
                && window.document.baseURI.match(new RegExp('(.*/)[^/]*$'))
                )
            {
                url = RegExp.$1 + url;
            } else {
                // do nothing because it seems like localdomain
            }
        }

        // dispatcher
        this._create_dispatcher();
        url += (url.indexOf('?') == -1 ? '?' : '&')
            + this._callback_param + '=' + encodeURIComponent('JSONScriptRequest._dispatchers[' + this._id + ']');

        // TODO: If the async flag is set to false, then the method must not return until the request has completed.
        //       Otherwise, it must return immediately. (See: open().)
        ;

        // Invoking send() without the data argument must give the same result as if it was invoked with null as argument.
        if (typeof data == 'undefined') {
            data = null;
        }

        if (data != null) {
            if (typeof data == 'string') {
                // If data is a DOMString, it must be encoded as UTF-8 for transmission.
            }
            else if (   typeof data == 'object'
                     && 'nodeType' in data
                     && data.nodeType == 9/*NODE_DOCUMENT*/) {
                // TODO: If the data is a Document, it must be serialized using the encoding given by data.xmlEncoding, if specified and supported, or UTF-8 otherwise [DOM3Core].
                if ('xmlEncoding' in data) {
                    // TODO: serialize and encode as data.xmlEncoding
                }
                else {
                    // TODO: serialize and encode as UTF-8
                }
                // TODO: If the argument to send() is a Document and no Content-Type header has been set user agents must set it to application/xml for XML documents and to the most appropriate media type for other documents (using intrinsic knowledge about the document).
            } else {
                // If data is not a DOMString or a Document the host language its stringification mechanisms must be used on the argument that was passed and the result must be treated as if data is a DOMString.
                data = data.toString();
            }
            url += '&' + data;
        }

        // TODO: If the user agent allows the specification of a proxy it should modify the request appropriately;
        //       i.e., connect to the proxy host instead of the origin server, modify the Request-Line and send Proxy-Authorization headers as specified.

        // TODO: If the user agent supports HTTP Authentication ([RFC2617]) it should  consider requests originating from this object to be part of the protection space that includes the accessed URIs and send Authorization headers and handle 401 Unauthorised requests appropriately.
        //       if authentication fails, user agents should prompt the users for credentials.

        // TODO: If the user agent supports HTTP State Mangement  ([RFC2109], [RFC2965]) it should  persist, discard and send cookies (as received in the Set-Cookie and Set-Cookie2 response headers, and sent in the Cookie header) as applicable.

        // TODO: If the user agent implements server-driven content-negotiation ([RFC2616]) it should set Accept-Language, Accept-Encoding and Accept-Charset headers as appropriate; it must not automatically set the Accept header.
        //       Responses to such requests must have content-codings automatically removed.

        // user, password
        if ( this._user != null || this._password != null) {
            // This will not work.
            var userinfo = ( this._user != null ? this._user : '' ) + ':' + ( this._password != null ? this._password : '' );

            url.replace(new RegExp('(https?://)(.+)', 'i'), RegExp.$1 + userinfo + '@' + RegExp.$2);
        }

        var script = document.createElement('script');
        script.src = url;
        script.type = 'text/javascript';
        script.charset = 'UTF-8';

        var head = document.getElementsByTagName('head')[0];
        script.onload = function() {head.removeChild(script)};
        // Once the request has been successfully acknowledged readyState must be set to 2 (Sent).
        this._readystatechange(2);

        head.appendChild(script);

        return;
    },

    abort: function() {
        // When invoked, this method must cancel any network activity for which the object is responsible and set all the members of the object to their initial values.
        var id = this._id;
        this._initialize_all();

        // register self destruction
        if (id != null) {
            JSONScriptRequest._dispatchers[id] = function(json) {
                delete JSONScriptRequest._dispatchers[id];
            };
        }
        return;
    },

    getAllResponseHeaders: function() {
        // If the readyState attribute has a value other than 3 (Receiving) or 4 (Loaded), user agents must raise an INVALID_STATE_ERR exception.
        if (this.readyState != 3 && this.readyState != 4) {
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 3 or 4');
        }
        // Otherwise, it must return all the HTTP headers, as a single string, with each header line separated by a CR (U+000D) LF (U+000A) pair.
        // The status line must not be included.
        var allResponseHeaders = '';
        for (var header in this._responseHeaders) {
            allResponseHeaders += header + ': ' + this._responseHeaders[header].toString() + '\x0D\x0A';
        }
        return allResponseHeaders;
    },

    getResponseHeader: function(header) {
        // If the header argument doesn't match the field-name production a SYNTAX_ERR must be raised.
        if (!header.match(JSONScriptRequest._RE['field-name'])) {
            throw new JSONScriptRequest.SYNTAX_ERR('header: ' + header);
        }
        // If the readyState attribute has a value other than 3 (Receiving) or 4 (Loaded), the user agent must raise an INVALID_STATE_ERR exception.
        if (this.readyState != 3 && this.readyState != 4) {
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 3 or 4');
        }

        // Header names must be compared case-insensitively to the method its argument (header).
        header = header.toUpperCase();

        var values = [];
        for (var i in this._responseHeaders) {
            // Header names must be compared case-insensitively to the method its argument (header).
            if (i.toUpperCase() == header) {
                values.push(this._responseHeaders[i]);
            }
        }

        if (values.length == 0) {
            // If no headers of that name were received, then it must return null.
            return null
        } else {
            // it must represent the value of the given HTTP header (header) in the data received so far for the last request sent, as a single string.
            // If more than one header of the given name was received, then the values must be concatenated, separated from each other by an U+002C COMMA followed by an U+0020 SPACE.
            return values.join(', ');
        }
    },

    _initialize: function() {
        // onreadystatechange  of type EventListener
        // -----------------------------------------
        // An attribute that takes an EventListener as value that must be invoked when readystatechange is dispatched on the object implementing the XMLHttpRequest interface.
        // Its initial value must be null.
        this.onreadystatechange = null;
        // readyState of type unsigned short, readonly
        // -------------------------------------------
        // The state of the object. The attribute must be one of the following values:
        // 0 Uninitialized: The initial value.
        // 1 Open: The open() method has been successfully called.
        // 2 Sent: The user agent successfully acknowledged the request.
        // 3 Receiving: Immediately before receiving the message body (if any). All HTTP headers have been received.
        // 4 Loaded: The data transfer has been completed.
        this.readyState = 0;
        // responseText of type DOMString, readonly
        // ----------------------------------------
        // TODO: Otherwise, it must be the fragment of the entity body received so far (when readyState is 3 (Receiving)) or the complete entity body (when readyState is 4 (Loaded)), interpreted as a stream of characters.
        // TODO: If the response includes a Content-Type understood by the user agent the characters are encoded following the relevant media type specification, with the exception that the rule in the final paragraph of section 3.7.1 of [RFC2616], and the rules in section 4.1.2 of [RFC2046] must be treated as if they specified the default character encoding as being UTF-8.
        // TODO: Invalid bytes must be converted to U+FFFD REPLACEMENT CHARACTER. If the user agent can't derive a character stream in accord with the media type specification, reponseText must be null.
        // Its initial value must be the null.
        this.responseText = null;
        // (XML -> JSON)
        // responseXML of type Document, readonly
        // --------------------------------------
        // TODO: Otherwise, if the Content-Type header contains a media type (ignoring any parameters) that is either text/xml, application/xml, or ends in +xml, it must be an object that implements the Document interface representing the parsed document.
        // TODO: If Content-Type did not contain such a media type, or if the document could not be parsed (due to an XML well-formedness error or unsupported character encoding, for instance), it must be null.
        // Its initial value must be null.
        this.responseJSON = null;
        // status of type unsigned short, readonly
        // ---------------------------------------
        // TODO: If the status attribute is not available an INVALID_STATE_ERR exception must be raised.
        // When available, it must represent the HTTP status code (typically 200 for a successful connection).
        // Its initial value must be 0.
        this.status = 0;
        // statusText of type DOMString, readonly
        // --------------------------------------
        // TODO: If the statusText attribute is not available an INVALID_STATE_ERR exception must be raised.
        // When available, it must represent the HTTP status text sent by the server (appears after the status code).
        // Its initial value must be the empty string.
        this.statusText = '';

        this._readystatechange(0);
    },

    _initialize_dispatcher: function() {
        if (this._id != null) {
            delete JSONScriptRequest._dispatchers[this._id];
            this._id = null;
        }
    },

    _initialize_all: function() {
        this._initialize();

        this._initialize_dispatcher();
        this._callback_param = 'callback';

        this._method   = null;
        this._url      = null;
        this._async    = true;
        this._user     = null;
        this._password = null;
        this._requestHeaders = {};
        this._responseHeaders = {};
    },

    _readystatechange: function(readyState) {
        if (this.readyState == readyState) {
            // It is not changed but continue to follow to
            // ActiveXObject of IE and XMLHttpRequest of Firefox.
        }
        this.readyState = readyState;

        // If the readyState attribute has a value other than 4 (Loaded), user agents must raise an INVALID_STATE_ERR exception.
        if (   this.readyState != 4
            && this.responseJSON != null)
        {
            // [LIMIT: the exception occurs at _readystatechange]
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 4, but' +
                                                          'responseJSON: ' + this.responseJSON + ' has a value');
        }

        // If the readyState attribute has a value other than 3 (Receiving) or 4 (Loaded), the user agent must raise an INVALID_STATE_ERR exception.
        if (   this.readyState != 3
            && this.readyState != 4
            && this.responseText != null)
        {
            // [LIMIT: the exception occurs at _readystatechange]
            throw new JSONScriptRequest.INVALID_STATE_ERR('readyState: ' + this.readyState + ' is other than 3 or 4, but' +
                                                          'responseText: ' + this.responseText + ' has a value');
        }

        // It must be available when readyState is 3 (Receiving) or 4 (Loaded).
        if (   (this.readyState == 3 || this.readyState == 4)
            && (this.status == 0 || this.statusText == '')
            )
        {
            throw new JSONScriptRequest.INVALID_STATE_ERR('status and statusText must be available when readyState is 3 or 4');
        }

        if (this.onreadystatechange) {
            this.onreadystatechange();
        }
        return;
    },

    _create_dispatcher: function() {
        this._initialize_dispatcher();
        for (this._id = 0; this._id < JSONScriptRequest._dispatchers.length; this._id++) {
            if (!this.id in JSONScriptRequest._dispatchers) {
                break;
            }
        }

        var owner = this;
        JSONScriptRequest._dispatchers[this._id] = (function() {
            return function(json) {
                owner._initialize_dispatcher();
                owner._dispatcher(json);
            };
        })();

        return;
    },

    _dispatcher: function(json) {
        // TODO: If the response is an HTTP redirect (status code 301, 302, 303 or 307), then it must be transparently followed (unless it violates security, infinite loop precautions or the scheme isn't supported).
        //       Note that HTTP ([RFC2616]) places requirements on user agents regarding the preservation of the request method during redirects, and also requires users to be notified of certain kinds of automatic redirections.

        // TODO: If something goes wrong (infinite loop, network errors) the readyState attribute must be set to 4 (Loaded) and all other members of the object must be set to their initial value.
        //       Note: In future versions of this specification user agents will be required to dispatch an error event if the above occurs.

        // TODO: If the user agent implements a HTTP cache ([RFC2616]) it should  respect Cache-Control request headers set by the author (e.g., Cache-Control: no-cache bypasses the cache).
        //       It must not  send Cache-Control or Pragma request headers automatically unless the user explicitly requests such behaviour (e.g., by (force-)reloading the page).
        //       304 Not Modified responses that are a result of a user agent generated conditional request must be presented as 200 OK responses with the appropriate content.
        //       Such user agents must allow authors to override automatic cache validation by setting request headers (e.g., If-None-Match, If-Modified-Since), in which case 304 Not Modified responses must be passed through.

        // TODO: If the user agent supports Expect/Continue for request bodies ([RFC2616]) it should insert Expect headers and handle 100 Continue responses appropriately.

        // Immediately before receiving the message body (if any), the readyState attribute must be set to to 3 (Receiving).
        if (typeof json == 'undefined' || json == null) {
            // TODO: This behavior is really ok?
            this.status = 400;
            this.statusText = 'Bad Request';
        } else {
            this.status = 200;
            this.statusText = 'OK';
        }
        this.responseText = '';
        this._readystatechange(3);

        // In case of a HEAD request readyState must be set to 4 (Loaded) immediately after having gone to 3 (Receiving).
        if (this._method == 'HEAD') {
            this._readystatechange(4);
        } else {
            this.responseText = JSONScriptRequest._toSource(json).replace(/^\(/, '').replace(/\)$/, '');

            this._readystatechange(3);

            this.responseJSON = json;
            // When the request has completed loading, the readyState attribute must be set to 4 (Loaded).
            this._readystatechange(4);
        }

        return;
    }
};

/*

=head1 NAME

JSONScriptRequest - Call the JSONP API like XMLHttpRequest

=head1 SYNOPSIS

  var req = new JSONScriptRequest();
  req.open('GET', 'http://www.example.com/jsonp');
  req.onreadystatechange = function() {
      if (req.readyState == 4) {
          alert(req.responseJSON);
      }
  };
  req.send(null);

=head1 DESCRIPTION

JSONScriptRequest calls JSON API by using the SCRIPT element.
It enables the cross-site request.

Its usage looks like XMLHttpRequest.
See the document of XMLHttpRequest for details.

=head2 Class Properties

=head3 responseJSON

  var json = req.responseJSON;

This attributes represents the response as a JSON object. NULL if the request is unsuccessful or has not yet been sent.

=head2 Constructor

=head3 JSONScriptRequest({...})

The following values can be specified for the argument.

=over

=item callback_param

The name of the callback parameter key. Default is 'callback'.

=back

=head1 TODO

=over

=item Implement the features that is not implemented yet.

=back

=head1 SEE ALSO

The XMLHttpRequest Object
L<http://www.w3.org/TR/XMLHttpRequest/>

=head1 AUTHOR

Hironori Yoshida <yoshida@cpan.org>

=head1 COPYRIGHT

  Copyright (c) 2006, Hironori Yoshida <yoshida@cpan.org>. All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the terms of the Artistic license. Or whatever license I choose,
  which I will do instead of keeping this documentation like it is.

=cut

*/
