// Degrader v 0.2.1
// Copyright (c) 2005 Justin Palmer (http://encytemedia.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
// and associated documentation files (the "Software"), to deal in the Software without restriction, 
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial 
// portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

// Helps aid in the extraction of your behaviour layer from an elements id attribute
// Example: id="remove-article23"
// If you set a rule for this then you could trigger an Ajax request to 
// remove the ojbect from the database and also remove an element from the dom
//
var Degrade = {
  // Generic global patterns
  patterns: {
    // (action-object-position in dom target) (e.g. update-articlelist23-top)
    action: /(^update|remove)-([a-z0-9]+)-*(top|bottom|before|after)*/i,
    // (effect-duration) (e.g. blindown-0.4)
    effect: /(^[a-z])-([.0-9]+)*/i 
  },
  
  // E(X)tract part of a string from the elements id
  // (e.g. Degrade.X(myele, /remove-([a-z0-9]+)/, 1))
  // This would return 'article23' if the elements id was remove-article23
  // @element: Element of whose id you'd like to check
  // @pattern: Regexp pattern to match on
  // @pos: Index in the match array you want to return
  X: function(element, pattern, pos) {
    if(pattern.test(element.id))
      return element.id.match(pattern)[pos];
    return false;
  },
  
  // Handle basic Ajax request
  // Use this to load the response of a request into a dom element
  // @url: The url to request a response from
  // @update: The dom node you want to update with the response
  // @ajaxOptions: Can be any of Prototype's Ajax options (see Ajax in prototype.js)
  genericRequest: function(url, update, ajaxOptions) {
    new Ajax.Updater({success: update}, url, 
          Object.extend({
            asynchronous: true, 
            evalScripts:  true,
            onComplete: function(request) {init() || Prototype.emptyFunction}
          }, ajaxOptions || {})
        ); 
        return false;
  }
  
}

Degrade.Degrader = Class.create();
Degrade.Degrader.prototype = {
  initialize: function(rules, options) {
    try {
      this.rules = rules || $A([]);
      this.applyRules();
    } catch(e) {
      alert(e.toString());
    }
  },
  
  // This is the workhorse that parses and applies all your rules
  applyRules: function() {
    for(var i = 0; i < this.rules.length; i++) {
      var rule = this.rules[i];
      var elements = $A(document.getElementsByTagName(rule.element));

      
      rule.pattern = rule.pattern || Degrade.patterns.action;
      var matches = this.grep(rule.pattern, elements);
      
      if(rule.element.toLowerCase() == 'form')
        this.falsifyForms($A(matches));
      
      if(rule.element.toLowerCase() == 'a')
        this.falsifyLinks($A(matches));
        
      for(var j = 0; j < matches.length; j++) {
        if(rule.onMatch)
          rule.onMatch.bind(this)(matches[j], rule);
        else
          Prototype.emptyFunction;
      }
    }
  },
  
  // Return and array of elements who's id matches the pattern
  // @pattern: Regexp Object
  // @elements: An array of elements you want to test
  grep: function(pattern, elements) {
    var results = [];
    elements.each(function(element) {
      if(pattern.test(element.id))
        results.push(element);
    });
    return results;
  },
  
  // Set forms to return false if submitted
  // @frms: An array of forms
  falsifyForms: function(frms) {
    frms.each(function(frm) {
      frm.onsubmit = function() { return false; }
    });
  },
  
  // Set links to return false if clicked
  // @links: An array of links
  falsifyLinks: function(links) {
    links.each(function(link) {
      link.onclick = function() { return false; }
    });
  }
}



// Adapated from Sam Stephensons getElementsByClassName
// Not used here, but could prove to be useful
// Grab all elements who's id matches the pattern
// @regex: Regexp object
// @parentElement: The element in which you want to start traversing the dom from
document.getElementsByIDRegex = function(regex, parentElement) {
  var children = (document.body || $(parentElement)).getElementsByTagName('*');
  return $A(children).inject([], function(elements, child) {
    if (regex.test(child.id)) {
      elements.push(child);
    }
    return elements;
  });
}


// Rules can have any amount of properties, 3 of which are required.
// element: The tagName of the element to apply your rule to
// pattern: A Regexp object that you want to match element id's on  (See Degrade.patterns for a few default ones)
// onMatch: The callback to use when a match has been made.  This function passes the element which triggered the 
//          callback on the rules that accompany it (e.g. onMatch(element, rules))
//
// Each rule is passed to the onMatch property so you may use those properties inside the function.
//
// An example of how your html could be formatted:
//
// <ul id="blurbs">
// <li id="blurb229">
//   <div>
//     <h3>A sweet title</h3>
//     <p>This is a degradable ajax post with no inline JS or onclick attributes.  Only sweet css.</p>
//     <div class="actions"><a href="/blurbs/destroy/229" id="remove-blurb229">delete</a></div>
//   </div>
// </li>
// </ul>
//
//  Note that if your using RubyonRails there is no need to use the remote helpers (form_remote_tag, link_to_remote, link_to_function, etc)
//  Just code them as if you we're not adding ajax funtionality.  In your controller you will need to handle request like:
//
//     def destroy
//       Blurb.find(params[:id]).destroy
//       unless(@request.xhr?)
//         flash[:notice] = 'Blurb was deleted successfully'
//         redirect_to :action => 'list'
//       else
//         render :nothing => true
//       end
//     end
//
//    Environment variable: ['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest' 
//
//
// var rules = $A([
//  {
//    element: 'a',
//    pattern: /^toggle-([\-a-z0-9]+)/i,
//    onMatch: function(element, rule) {
//      var target = Degrade.X(element, rule.pattern, 1);
//      Event.observe(element, 'click', function(){Element.toggle(target)});
//    }
//  },
//  
//  {
//    element: 'a',
//    pattern: /^request-([\-a-z0-9]+)/,
//    onMatch: function(element, rule) {
//      Event.observe(element, 'click', function() { 
//        Degrade.genericRequest(element.href, Degrade.X(element, rule.pattern, 1))
//      });
//    }
//  },
//  
//  {element: 'form'},
//  
//  {
//    element: 'input', 
//    pattern: /^archive-(client[0-9]+)/,
//    onMatch: function(element, rule) {
//      var client = Degrade.X(element, rule.pattern, 1);
//      Event.observe(element, 'click', function() {Live.archive(client)});
//    }
//  }  
// ]);
//
//
// Any initialization that needs to happen on a page load
//
// function init() {
//  hideThese = $A(document.getElementsByClassName('hide'));
//  hideThese.each(function(element) {
//    element.style.display = "none";
//  })
// }