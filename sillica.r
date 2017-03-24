REBOL [
	; -- Core Header attributes --
	title: "Glass sillica core module"
	file: %sillica.r
	version: 1.0.1
	date: 2014-6-4
	author: "Maxim Olivier-Adlhoch"
	purpose: {Low-level components  and functions used by many GLASS modules}
	web: http://www.revault.org/modules/sillica.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'sillica
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/sillica.r

	; -- Licensing details  --
	copyright: "Copyright © 2014 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2014 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		v1.0.0 - 2013-09-18
			-License changed to Apache v2
		v1.0.1 - 2014-06-04
			-Tweaks to the stylesheet include changing default font to Arial (cleaner rendering)
			-bold font render now thicker and less fuzzy (much nicer).
			-layout() can now set the offset before display directly via /position refinement (works alongside /center).
			
			
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Sillica is a utility library which evolves rapidly and will be constantly changing
		from release to release.
		
		Its an internal module which usually doesn't need to be used directly.
		
		The only reason for this module really is to provide components which are used throughout
		the GLASS framework or which are generic enough that they shoudn't be buried deep
		within another module.
		
		The current theme information is also setup in sillica, and is very basic.  They
		are all set globally, and start with the prefix 'theme_ .  This allows us to 
		quickly find all theme-using code in the future so we can replace it with proper
		shader stuff.
		
		also, quite a few primitives are defined here.  Some of them are complex, some are simple
		but practically all are ugly code which evolved slowly out of the specific needs 
		marbles.  Some of them have little quirks which alleviate AGG rendering bugs, and others
		are just plain hacker type code.
		
		These will all be completely revised when the shader system is defined, and will most
		probably be stored in a new primitives.r module at that time.
		
		another noteworthy aspect of the sillica module is that it implements the style sheet 
		and the low-level marble allocation functions.

		at some point, the sillica library might disapear altogether, but for now, its a generic
		dumping place for newer or oft-used code.
		
		note that some of the functions here are exported by the glass.r module.  this is always
		how it should be done.  The glass.r library is the high-level api which is least subject
		to change, so you should stick with using its stubs, even if they are exactly the same
		as the sillica library right now.
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'sillica
;
;--------------------------------------

slim/register [

	;- LIBS
	slim/open/expose 'utils-blocks  none [ find-same ] 
	slim/open/expose 'utils-words  none [ swap-values ] 
	slim/open/expose 'utils-strings  none [ coerce-string ] 
	
	glob-lib: slim/open/expose 'glob none [ !glob ] 
	
	
	liquid-lib: slim/open/expose 'liquid none [!plug [liquify* liquify ] [content* content] [fill* fill] [link* link] [unlink* unlink]]

	slim/open/expose 'bulk none [
		is-bulk? symmetric-bulks? get-bulk-property get-bulk-label-column get-bulk-labels-index 
		set-bulk-property set-bulk-properties bulk-find-same search-bulk-column filter-bulk 
		get-bulk-row bulk-columns bulk-rows copy-bulk sort-bulk insert-bulk-records add-bulk-records 
		make-bulk clear-bulk 
	]


	;- WORD ALIASES
	;-     max*  min*
	max*: :max
	min*: :min
	

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------

	;-    master-stylesheet:
	; the default master marble stylesheet
	; stored as pairs of style names and reference marble objects
	master-stylesheet: []
	
	
	;-    rebol-version:
	rebol-version: system/version/1 * 10000 + ( system/version/2 * 100) + system/version/3
	
	
	;-    clip-regions
	;
	; between refreshes, marbles can ask the display to clip to them.
	;
	; this block is clear at each redraw.
	clip-regions: []
	
	
	;-    debug-mode?:
	;
	; this is a level based setup.
	;
	; 0= no debug
	; 1= a few print outs, like the refresh "." check
	; 2= debug printouts
	; 3= heavy and application slowing debug, ex: AGG block saved to disk.
	debug-mode?: 0
	
	;-    glass-debug-dir:
	set 'glass-debug-dir join what-dir %debug/
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- THEME
	;
	;-----------------------------------------------------------------------------------------------------------

	;base-font: make face/font [style: none size: 13 name: "Trebuchet MS"]
	;base-font: make face/font [style: none size: 13 name: "Arial"]
	;base-font: make face/font [style: none size: 13 name: "Tahoma"]
	;base-font: make face/font [name: "verdana" size: 13 style: none bold?: false]

	
;	base-font: make face/font [name: "Tahoma" size: 13 style: none bold?: false]
;	base-font: make face/font [name: "Trebuchet MS" size: 13 style: none bold?: false]
;	base-font: make face/font [name: "Lao UI" size: 13 style: none bold?: false]
;	base-font: make face/font [name: "Arial" size: 14 style: none bold?: false]
	base-font: any [
		all [
			value? 'glass-font-overide
			glass-font-overide
		]	
		
		;---
		; this font is used if no other font is specified in the source before
		; loading sillica.
		make face/font [name: "Segoe UI" size: 13 style: none bold?: false]
		
	]
	mono-font: make face/font [name: font-fixed bold?: false char-width: 7]
	
	
	;----------------------------------
	;-     default BASE theme values
	;
	; these have to evaluate as absolute values, they will be used
	; by other derived theme values
	;--------------------------------------
	set 'theme-mono-font mono-font
	set 'theme-base-font base-font 
	set 'theme-bg-color  white * 0.97
	set 'theme-color  40.100.255
	set 'theme-flat-color  120.180.255
	set 'theme
	

	
	;----------------------------------
	; custom theme management
	;
	; use this to set the core (BASE) theme values.
	;--------------------------------------
	attempt [
		;slim/von
		slim/open 'app-theme-base none
	]
	
	
	
	
	;-        -fonts
	;----------------------------------
	; default theme management
	;--------------------------------------
	set 'theme-knob-font make theme-base-font [size: 14 ];  bold?: true]
	set 'theme-small-knob-font make theme-base-font [size: 12 bold?: none]
	set 'theme-menu-item-font make theme-base-font [size: 12 bold?: none]
	set 'theme-list-font make theme-base-font [size: 11 ]
	;set 'theme-grid-font make theme-base-font [size: 12 name: "Arial" style: 'bold]
	set 'theme-grid-font make theme-base-font [size: 12 name: "Arial" style: none]
	
	set 'theme-field-font make theme-mono-font [size: 12]
	set 'theme-editor-font make theme-mono-font [size: 12]
	
	set 'theme-label-font make theme-base-font [size: 12  ] ;aliased?: true]
	set 'theme-headline-font make theme-base-font [size: 13  bold?: true]
	set 'theme-title-font make theme-base-font [size: 20]
	set 'theme-subtitle-font make theme-base-font [size: 15 bold?: true]
	set 'theme-requestor-title-font make theme-base-font [size: 14 bold?: true]
	set 'theme-editor-char-width 7
	set 'theme-field-char-width 7
	
	set 'theme-frame-font make theme-base-font [size: 19 ] ; bold?: true]
			
	
	;-        -colors
	; these are set globally
	set 'shadow 0.0.0.128
	set 'light-shadow 0.0.0.200
	set 'theme-hi-color theme-flat-color ;theme-color + 0.0.0.150
	set 'theme-recess-color theme-bg-color * .95
	set 'theme-window-color theme-bg-color
	set 'theme-border-color white * 0.75
	set 'theme-knob-border-color white * 0.70
	set 'theme-knob-color white * 0.90
	set 'theme-glass-color theme-color
	set 'theme-glass-transparency 175
	set 'theme-bevel-color white * 0.85
	set 'theme-requestor-bg-color theme-bg-color
	set 'theme-progress-bg-color white
	set 'theme-select-color theme-color + 80.80.80
	
	set 'theme-frame-color white * 0.4
	set 'theme-frame-label-color white 
	set 'theme-frame-bg-color theme-bg-color
	
	set 'theme-editor-comment-color blue
	


	;----------------------------------
	; custom theme management
	;
	; you do not need to change all theme values, and you MUST use above set method, since they are defined globally.
	;--------------------------------------
	attempt [
		slim/open 'app-theme-custom none
	]



	empty-face: make face [
		size: 0x0
		font: none
		edge: none
		;para: none
		effect: none
		text: none
		offset: 0x0
		feel: none
		pane: none
		
	]
	

	;-     Text-sizer: [ ... ]
	text-sizer: make empty-face [
		size: 200x200
		para: make para [wrap?: false]
		font: theme-base-font
	]
	
	
	;-     Label-text-sizer: [ ... ]
	; this is used exclusively by the label-dimension function
	label-text-sizer: make face [
		size: 200x200 
		para: make para [wrap?: false]
		edge:  none
		font: theme-base-font
		para: make para []
		para/origin: 0x0
		para/margin: 0x0
	]
	
	
	
	;--------------------------
	;-     Line-rendering-ctx: [ ... ]
	;
	; used to store optional line rendering specifications.
	;
	; these include image prefix, indents, colors and more.
	;
	; this is shared in multiple functions.
	;
	; most values can be set to none and ignored by function using/managing it.
	;--------------------------
	line-rendering-ctx: context [
		text-color: black  ; tuple!    -  sets the text color (careful, if none, line will render invisible)
		bg-color:   none  ; tuple!    -  draws an opaque bg behind the line of text (if none, we leave bg intact)
		edge-color: none   ; tuple!    -  draws a box around a line of text
		
		indent: 0          ; integer!  -  MUST ALWAYS BE AN INT  -  an indent to put the line at, clipping will adjust for this. 
		
		image: none        ; image!    -  centers an image to the left of line start. is affected by indent.
		
		width: none        ; integer!  -  clips text to this width.
		
		font: base-font    ; object!   -  use this font in size calculations and rendering.
		
		text: none         ; string!   -  the text to display for the line (may be clipped)
		clipped?: false    ; logic!    -  is the text currently clipped?
		                   ;              when text is changed, clipped? should be reset to false.
		
		sizer: text-sizer  ; object!   -  MUST be set to a face setup for use in text sizing operations.
		                   ;              the default should never have to be changed 
		                   
;		arrow?: none       ; logic!    -  if true, an arrow is displayed when text is clipped.
		
		
		
		defaults: [
			text-color: black  ; tuple!    -  sets the text color (careful, if none, line will render invisible)
			bg-color:   none  ; tuple!    -  draws an opaque bg behind the line of text (if none, we leave bg intact)
			edge-color: none   ; tuple!    -  draws a box around a line of text
			
			indent: 0          ; integer!  -  MUST ALWAYS BE AN INT  -  an indent to put the line at, clipping will adjust for this. 
			
			image: none        ; image!    -  centers an image to the left of line start. is affected by indent.
			
;			font: none         ; object!   -  use this font in size calculations and rendering.
			
			text: none         ; string!   -  the text to display for the line (may be clipped)
			clipped?: false    ; logic!    -  is the text currently clipped?
			                   ;              when text is changed, clipped? should be reset to false.
		]
		
		;--------------------------
		;-         set-defaults()
		;--------------------------
		; purpose:  give a block to execute at each call to reset.  this block is bound to the spec, 
		;           so it doesn't need to be bound for each line.  
		;
		;           also note that since the block is bound, it is faster than using object lookup. [spec/font: none] is slower than [ font: none]
		;
		; inputs:   a block of code to execute at each reset() 
		;
		; notes:    be careful, you may end up running code outside the spec (but may do so voluntarily :-)
		;
		;           words in given block will keep their binding if they are not part of spec.
		;--------------------------
		set-defaults: funcl [
			defaults-script [block!]
		][
			vin "set-defaults()"
			self/defaults: bind/copy defaults-script self
			vout
		]
		
		;--------------------------
		;-         reset()
		;--------------------------
		; purpose:  reset attributes which typically change from one line to another in a list.
		;--------------------------
		reset: funcl [
		][
			vin "reset()"
			if block? self/defaults [
				do self/defaults
			]			
			vout
		]
	]
	
	
	


	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;-   
	;- PARSE RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	non-space: complement charset " "
	set '**letter charset [#"a" - #"z" #"A" - #"Z"]
	set '**whitespace charset "^- ^/"
	
	

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- UTILITY FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------

	
	;--------------------------
	;-     new-bulk-list()
	;--------------------------
	; purpose:  generate a bulk from scratch,. ready for use by listers.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    items is a simple list, not a bulk data.. their first column is converted to string.
	;
	; tests:    
	;--------------------------
	new-bulk-list: funcl [
		/with items [block! hash!]
	][
		data: any [data []]
		if items [
			data: clear []
			foreach item items [
				append data reduce [coerce-string item [] item ]
			]
		]
		make-bulk/records/properties 3 data copy [ label-column: 1 ]
	]
	
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- EVENT FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     do-event()
	;--------------------------
	; purpose:  given an event object from the event module, execute the action (in marble/actions) 
	;           which corresponds to the event.
	;
	;            this is a high-level callback mechanism aimed at individual marbles
	;
	;            when events occur for SOME actions, depending on the style, it
	;            just calls [ do-action event ] and it will hook into the marble's action context.
	;
	;            the specify dialect may modify an instance's action context
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	do-event: funcl [
		event [object! none!]
		/as act [word!]
	][
		;vin "do-event()"
		;vprint event/action
		if attempt [
			if as [event/action: act]
			all [
				word? act: event/action
				object? actions: event/marble/actions
				function? action: get/any in actions act
			]
		][
			action event
		]
			
		;vout
	]
	
	
	

	;-----------------
	;-     do-action()
	; purpose:  execute the default event for a face, which is usually called the 
	;           'ACTION event.
	;
	;            this event isn't tied to a specific event type, but rather the 'ACTION
	;            event is raised by the marble's event handler from another event.
	;
	;            for example:
	;                -buttons when successfully clicked will call action
	;                -fields call action when their text change
	;
	;  notes     some marble types have alternate actions, (buttons have right click, 
	;            text fields have keystroke actions, etc) in this case, you can use the
	;            /alternate refinement to trigger the appropriate one.
	;
	;            using do-action, you can easily cause any marble to generate an effect,
	;            just as if the user had actually interacted with it.
	;-----------------
	do-action: func [
		event [object! none!]
		/alt
		/local action marble
	][
		action: pick [ALT-ACTION ACTION] true? alt
		do-event/as event action
	]
		
		

	
	
	;--------------------------
	;-     on-event()
	;--------------------------
	; purpose:  easily attach an event handler on any marble for any specific event.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    when given as a block, the actions is built with ,  funcl so everything is local.
	;            if you really need to use global data, do not use its SET word or use a global object with a path.
	;            ex:   globals/my-gbl-value: 666 
	;
	; tests:    
	;--------------------------
	on-event: funcl [
		marble [object!] 
		type   [word!]  "event type to switch"
		action [block! function!] "functions specs are not verified, make sure they comply"
	][
		vin "on-event()"
		either in marble 'actions [
			if block? action [
				efunc: funcl [
					event [object!]
				] action
			]
		
			marble/actions: make marble/actions compose [
				(to-set-word type )  :efunc
			] 
		][
			to-error "on-event() requires a marble object .... no 'ACTIONS attribute found in given object."
		
		]
		
		vout
	]
	
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- RENDERING MANAGEMENT
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     clip-to-marble()
	;--------------------------
	; purpose:  given a marble, the next rendering will be clipped to that marble
	;           if several marbles require rendering, the clip region will be
	;           tabulated and redraw will encompass all regions.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	clip-to-marble: funcl [
		marble [object!] "MUST be a valid and visible marble in the window."
		viewport [object!]
	][
		vin "clip-to-marble()"
		
		;<TO DO> support view pane offsets
		clip-regions: viewport/clip-regions
		either empty? clip-regions [
			append clip-regions pos:  content* marble/material/position
			append clip-regions pos + ( content* marble/material/dimension ) 
		][
			change clip-regions       min clip-regions/1 content* marble/material/position
			change next clip-regions  max clip-regions/2 (( content* marble/material/dimension ) + ( content* marble/material/position ) ) 
		]
		
		vout
	]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LINE RENDERING FUNCTIONS
	;
	; all of the following function use and manipulate the 'line-rendering-ctx object!
	;-----------------------------------------------------------------------------------------------------------

	
	;--------------------------
	;-     clip-string()
	;--------------------------
	; purpose:  given a line-spec sets the text-end based on current line-spec values.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    we return a block with two values, it is always the same block reference.
	;           the returned string is always a COPY of the input string.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	clip-string: funcl [
		spec [object!]
		;text [string!]  "String to render"
		;line-spec [block! none!] "Advanced line drawing specs, used in various styles.  each line in a list uses its own."
		;width [integer!]  "max width of line, in pixels"
		;text-sizer [object!] "given here, so we don't have to manipulate it at each string, in a list."
	][
		vin "clip-string()"
		;print ">>>>>>>>>>>>>>>>>>>>>>"
		;rval: clear head [] ; reused in each call to clip-string() to save processing. its your job to make sure to copy any values, if you need to.
		
		width: spec/width
		;?? width
		indent: spec/indent
		;?? indent
		caret: 1x0 * ( spec/width - spec/indent ) + -1x5
		;?? caret
		text: trim/tail spec/text
		;?? text
		spec/sizer/text: text
		spec/sizer/font: spec/font
		text-end: offset-to-caret spec/sizer caret
		;?? text-end

		;----
		; make space for arrow
		either empty? text-end [
			spec/clipped?: false
			spec/text: text
		][
			spec/text: copy/part text text-end
			spec/clipped?: true
		]
		
		;print "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"		
		vout
		;rval
		spec
	]
	
	
	
	
	;--------------------------
	;-     apply-spec()
	;--------------------------
	; purpose:  applies the given spec into a line-rendering-ctx object.
	;
	; inputs:   a spec block which is parsed.
	;
	; returns:  the input ctx
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	apply-spec: funcl [
		lctx [object!]
		spec [block!]
	][
		vin "apply-spec()"
		
		clr-counter: 1
		
		; we silently ignore any incompatible data... these might be used by other subsystems.
		parse/all spec [
			any [
				set data integer! (
					lctx/indent: data
				)
				| set data tuple! (
					switch clr-counter [
						1 [lctx/text-color: data]
						2 [lctx/bg-color: data]
						3 [lctx/edge-color: data]
					]
					++ clr-counter
				)
				
				| set data object! (
					lctx/font: data
				)
				
				| set data image! (
					lctx/image: data
				)
				
				| skip
			]
		]
		vout
	]
		
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GRAPHIC PRIMITIVE FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	;-----------------
	;-    label-dimension()
	;-----------------
	label-dimension: func [
		text
		font
		/width w
		/height h
		/wrap? ww
		;/align a
		/local size b
	][
		
		label-text-sizer/size: 10000x10000
		if wrap? [
			label-text-sizer/size/x: ww
		]
		
		label-text-sizer/para/wrap?: wrap?
		label-text-sizer/font: font
		
		label-text-sizer/text: text
		
		;label-text-sizer/font/align: any [a 'left] ; should not really make any difference
		;label-text-sizer/font/offset: 0x0
		case [
			width [
				label-text-sizer/size/x: w
				size: size-text label-text-sizer
				size/x: w
				size
			]
			height [
				label-text-sizer/size/y: h
				size: size-text label-text-sizer
				size/y: h
				size
			]
			true [
				size-text label-text-sizer
			]
		]
	]
	
	
	
	;-----------------
	;-    top-half()
	;-----------------
	top-half: func [
		position
		dimension
		/absolute "dimension is an absolute value, calculate its delta"
	][
		if absolute [dimension: dimension - position - 1x1]
		reduce [position (position + (1x0 * dimension) + (0x1 * dimension / 2) )]
	]
	
	;-----------------
	;-    bottom-half()
	;-----------------
	bottom-half: func [
		position
		dimension
	][
		reduce [( 0x1 * dimension / 2 + position) (position + dimension - 1x1)]
	]
	
	
	
	;-----------------
	;-    clip-strings()
	;
	; more effective to call this with a block of strings, even if there is only one.
	;
	; return value is always a block whatever the input was.
	;
	; note: we trim spaces at tail to make sure offset-to-caret returns proper values... its buggy... 
	;-----------------
	clip-strings: func [
		strings [string! block!]
		width [integer! pair!]
		font
		/local item item-end align?
	][
		vin [{clip-strings()}]
		
		align?: font/align
		
		; make sure box fits some text
		width: 1x0 * width +  -1x5
		text-sizer/size: 10000x100
		text-sizer/para/wrap?: false
		text-sizer/font: font
		
		text-sizer/font/align: 'left
		text-sizer/edge:  none
		text-sizer/font/offset: 0x0
		text-sizer/para/origin: 0x0
		text-sizer/para/margin: 0x0
		
		unless block? strings [
			strings: compose [(string)]
		]
		
		unless empty? strings [
			until [
				item-end: ""
				item: trim/tail first strings
				text-sizer/text: item
				item-end: offset-to-caret text-sizer width
				
				; make space for arrow
				either empty? item-end [
					item-end: none
				][
					item-end: -1 + index? item-end 
				]
				strings: change/part strings reduce [item  item-end] 1
				
				tail? strings
			]
		]
		; restore original text alignment.
		font/align: align?
		vout
		strings
	]
	
	
	

	;-----------------
	;-    prim-bevel()
	;-----------------
	prim-bevel: func [
		position
		size
		color
		contrast
		width
		/invert
		/local start end
	][
		vin [{prim-bevel()}]
		vout
		size: size - 1x1
		
		either invert [
			;print "bevel"
			compose [
				line-cap round
				line-width (width)
				pen (color - (white * contrast))
				line (position + (0x1 * size)) (position) (position + (1x0 * size))
				pen (color + (white * contrast))
				line (position + (0x1 * size)) (position + size) (position + (1x0 * size))
				
				line-width 1
				pen black
				box (position + (width / 2) ) (position + size - (0.5 * width ))
			]
		][
			compose [
			
				fill-pen none
				line-cap round
				line-width (width)
				
				pen (color - (white * contrast))
				line (position + ( size * 0x1) + (width / 2 * 1x-1)) (position + size - (width / 2)) (position + (1x0 * size)  + ( width / 2 * -1x1))
				
				pen (color + (white * contrast))
				line (position + ( size * 0x1) + (width / 2 * 1x-1)) (position  + (width / 2)) (position + (1x0 * size) + ( width / 2 * -1x1))
				
			]
		]
	]
	
	
	;-----------------
	;-    prim-X()
	;-----------------
	prim-X: func [
		position
		size
		color
		width
		/local colors
	][
		vin [{prim-x()}]
		vout
		size: size - 1x1
		compose [
			line-width (width)
			pen (color)
			line (position + (0x1 * size)) (position + (1x0 * size))
			line (position ) (position + size) 
		]
	]
	
	;-----------------
	;-    prim-label()
	;-----------------
	prim-label: func [
		text [string!]
		position [pair!]
		size [pair!]
		color [tuple!]
		font [object! none! integer!]
		align [word! none!] "Polar coordinates (N NE E SE S SW W NW) or 'center"
		/aliased "switches to aliased text carefull... doesn't respond to transform matrix"
		/pad p [integer! pair!] "If some of the align values are on the edges, this will push the text opposite to that edge"
		/local text-size offset font-size
	][
		vin [{prim-label()}]

		;probe text
		;probe color
		
		p: any [p 0x0]

		if integer? font [
			font-size: font
			font: none
		]
		font: any [font theme-base-font]
		
		
		if all [
			integer? font-size
			font-size <> font/size 
		][
			font: make font [size: font-size]
		]
		;font/valign: 'top
		;font/offset: 0x0
		
		;probe "--------------------------"
		;?? size
		
		text-size: label-dimension text font
		
		;?? text-size
		offset: switch/default align [
			W WEST left [
				p: p * 1x0
				position + (1x0 * p/x) + (size - text-size / 2 * 0x1) + p
			]
			E EAST right [
				p: p * 1x0
				position - (1x0 * p/x) + (size - text-size * 1x0 ) + (size - text-size / 2 * 0x1)  - p
			]
			S SOUTH bottom [
				p: p * 0x1
				(size - text-size / 2 * 1x0) + (size - text-size * 0x1) + position  - p;+ (p/x * 1x0)
			
			]
		][
			; default is center
			size - text-size / 2 + position  ;+ (p/x * 1x0)
		]
		
			
		render-mode: any [
			all [aliased 'aliased] 
			all [
				in font 'aliased?
				font/aliased?
				'aliased
			]
			'vectorial
		]
		
		vout
		compose [
			font (font)
			(either render-mode = 'aliased [
				compose [pen (color)]
			][[]]
			)
			;fill-pen 200.0.0.200
			;box (position) (size + position)
			(
				either font/bold? [
					compose [line-width 0.5 pen (color)]
				][[]]
			)
			fill-pen (color )
			text (text) (offset) (render-mode)
			; workaround: fix a bug in AGG where vectorial text break alpha of following element.
			line 0x0 0x0
		]
	]
	
	
	
	;-----------------
	;-    prim-glass()
	;-----------------
	prim-glass: func [
		from "box start" [pair!]
		to "box end"  [pair!]
		color [tuple!]
		transparency [integer!] "0-255"
		/corners corner
		/only
		/no-shine
		/local height tmp border-clr
	][
		transparency: 0.0.0.255 * ( transparency / 255 )
		
		
		tmp: min from to
		to: max from to
		from: tmp
		
		border-clr: unless only [
			(black + transparency)
		]
		;corner: any [corner 0] ; HANGS AGG (probably trying to create an arc of radius 0  :-)
		;border-clr: none
		;print "!!!"
		compose [
			; glass color
			line-width 1
			fill-pen linear (from) 1 (height: second (to - from)) 90 1 1 ( color * 0.8 + (white * 0.2) + transparency ) ( color + transparency ) (color * 0.8 + transparency)
			pen (border-clr)
			box  ( from ) ( to ) corner
			
			
			; shine
			(either no-shine [				
				compose [
					pen none
					fill-pen (255.255.255.225)
					box ( top-half/absolute  from  to  ) corner
				]
			][
				compose [
					pen none
					fill-pen (255.255.255.175)
					box ( top-half/absolute  from  to  ) corner
				]
			])
			
			
			; shadow
			fill-pen linear (from: from * 1x0 + (to - 0x5 * 0x1)) 1 5 90 1 1 
				0.0.0.255
				0.0.0.225
				0.0.0.180
			box ( from ) ( to ) corner
			
			pen border-clr ;(black + transparency)
			line (from * 1x0 + (to * 0x1)) (to )
			
		]
	]
	
	
	;-----------------
	;-    prim-text-area()
	;-----------------
	prim-text-area: func [
		position [pair!]
		size [pair!] "Items will be shown until dimension height is hit"
		lines [block!] "A one column bulk. "
		font [object!] "A properly setup font which has a char-width attribute."
		leading [integer!]  "Added distance between lines."
		left [integer!] "First visible character to the left of view."
		top [integer!]  "First line to display, regardless of columns in list."
		cursors [block! none!] "A block of pairs which is used to display cursors"
		selections [block! none!] "A block of pairs which is used to display selections areas relative to the cursors"
		crs-clr [tuple!] "Color of cursors."
		text-color [tuple!] "Color of text."
		selection-color [tuple!]
		/cursor-lines cline-clr [tuple!]"If used, will add a colored line behind the cursors."
		
		/local  blk char-width colored-lines font-box chars line-count cursor-offset clines pos cpos
				l line-height line selection
		
	][
		vin [{prim-text-area()}]
		blk: clear []            ; saves on memory recycling
		
		
		;print "LINES: "
		;probe lines
		
		
		; font MUST be setup properly (no fallback)
		either char-width: get in font 'char-width [
			lines: next lines											; skip bulk header
			colored-lines: clear []                                     ; accumulate lines we've already colored, so we don't overlap several draw boxes for nothing.
			font-box: (char-width * 1x0 + (font/size + leading * 0x1))  ; size of a single char
			chars: to-integer size/x / char-width                       ; max width of view in characters
			line-count: to-integer size/y / font-box/y                  ; max number of lines in display
			cursor-offset: (left * -1x0 + ( top * 0x-1)) * font-box     ; offset (in pixels) of cursor drawing, based on text scrolling
			
			
			if cursors [
				clines: clear []
				foreach cursor cursors [
					; make sure cursor is visible
					unless any [
						cursor/y < top
						cursor/y > (top + line-count)
					][
						pos: cursor * font-box + position + cursor-offset
						
						; add line bg color?
						if cline-clr [
							unless find colored-lines cursor/y [
								append blk compose [
									fill-pen (cline-clr) 
									pen none 
									box (  cpos: ( (pos * 0x1 ) + (position * 1x0) ) )   (cpos + (size  * 1x0) + (font-box * 0x1))
								]
								append colored-lines cursor/y
							]
						]
							
						; add cursors
						unless any [
							cursor/x < left
							cursor/x > (left + chars)
						][
							append blk compose [
								line-width 3 pen (crs-clr) fill-pen none
								line (pos) (pos + (font-box * 0x1))
							]
						]
					]
				]
			]
			
			
			
			;--------------------------------
			; draw selections
			;--------------------------------
			append blk compose [pen none fill-pen (selection-color)]
			until [
				if selection: pick selections 1 [
					
					if all [
						cursor: pick cursors index? selections
						cursor <> selection 
					][
					
						if any [
							cursor/y < selection/y
							all [cursor/y = selection/y cursor/x < selection/x]
						][
							swap-values cursor selection
						]
						
						until [
							if all[
								line: pick lines selection/y 
								top <= selection/y
								top + line-count >= selection/y
							][
								; calculate box of current line to highlight
								selection/x: max selection/x left
								either cursor/y = selection/y [
									cpos: (cursor/x - selection/x - 1)
									if cpos >= 0 [
										pos: (selection * font-box) + cursor-offset + position
										cpos: pos + (cpos * font-box * 1x0) + font-box
										append blk reduce ['box pos cpos]
									]
								][
									if 0 <= cpos: (length? line) - selection/x [
										pos: (selection * font-box) + cursor-offset + position
										cpos: pos + ( cpos * font-box * 1x0) + font-box
										append blk reduce ['box pos cpos]
									]
								]
							]
							selection: selection + 0x1
							selection/x: 1
							selection/y > cursor/y
						]
					]
				]
				tail? selections: next selections
			]
			
			
			
			;--------------------------------
			; draw text
			;
			; we now optimise the string handling so it copies as little strings as it must
			;--------------------------------
			l: 1                                 ; line count
			pos: leading * 0x1 + position - 0x2  ; position accumulator
			line-height: (0x1 * font-box)        ; prepared line position incrementor
			lines: at lines top
			
			append blk compose [font (font) line-width 0 pen none fill-pen (text-color)  ]
			until [
				unless empty? lines [
					line: first lines  ; get current line
					;probe type? line
					line: any [
						all [
							left + (length? line) < chars
							at line left
						]
						copy/part at line left chars
					]
					
					append blk compose [  line-width 0  text ( pos) (line) vectorial ]
					pos: pos + line-height
				]
				any [
					tail? lines: next lines
					(l: l + 1) > line-count
				]
			]
			
			
		][
			print "Error: given font doesn't have char-width property and is incompatible with prim-text-area()"
		]
		vout
		
		; uncomment for debugging
		;append blk compose [pen green box (position) (position + size  - 1x1)]
		append blk [box 100000x100000 100001x100001 ]
		;?? blk
		blk
	]
	
	
	
	
	
	;-----------------
	;-    prim-list()
	;
	; given a bulk, construct n draw block which represents it, clipped to a specifed area.
	;-----------------
	prim-list: funcl [
		position [pair!]
		dimension [pair!] ; items will be shown until dimension height is hit
		font [object!]
		leading [integer!] "added distance between lines"
		items [block!] ; a bulk. will use label-column, if specified in its properties or column one by default, otherwise.
		start [integer!] ; first line to display, regardless of columns in list
		chosen [block! none!]
		pen [tuple! none!]
		fill-pen [tuple! none!]
		/arrows "add arrows to indicate the text goes out of bounds of list"
;		/local end blk label payload columns line-height i pos length arrow-offset list text highlight-start
;			   label-column spaces number-of-lines spec-column 
;			   
;			   spec
	][
		vin [{prim-list()}]

		;==========================================
		;align?: font/align
		;
		;; make sure box fits some text
		;width: 1x0 * width +  -1x5
		;text-sizer/size: 1000x100
		;text-sizer/para/wrap?: false
		;text-sizer/font: font
		;
		;text-sizer/font/align: 'left
		;text-sizer/edge:  none
		;text-sizer/font/offset: 0x0
		;text-sizer/para/origin: 0x0
		;text-sizer/para/margin: 0x0
		;
		;unless block? strings [
		;	strings: compose [(string)]
		;]
		;
		;unless empty? strings [
		;	until [
		;		item-end: ""
		;		item: trim/tail first strings
		;		text-sizer/text: item
		;		item-end: offset-to-caret text-sizer width
		;		; make space for arrow
		;		either empty? item-end [
		;			item-end: none
		;		][
		;			item-end: -1 + index? item-end 
		;		]
		;		strings: change/part strings reduce [item  item-end] 1
		;		
		;		tail? strings
		;	]
		;]
		;; restore original text alignment.
		;font/align: align?
		;==========================================
		
		columns: 2 ; this might be programable at some point.
		blk: head clear head [] ; we reuse the same block at each eval.
		end: position + dimension
		
		; rebol's left to right math makes the following seem wrong but proper result occurs.
		unless columns: get-bulk-property items 'columns [
			;------
			; incompatible-input... bail!
			return []
		]
			
		column: any [
			get-bulk-property items 'label-column 
			1
		]
		spec-column: any [
			get-bulk-property items 'gfx-spec-column 
			2
		]
		
		line-height: font/size + leading * 0x1
		number-of-lines: to-integer ( dimension/y  /  line-height/y )
		
		in-items: items
		
		;?? number-of-lines
		
		items: extract/index  (copy/part at next in-items ((start - 1) * columns + 1) (number-of-lines * columns)) columns column
		specs: extract/index  (copy/part at next in-items ((start - 1) * columns + 1) (number-of-lines * columns)) columns spec-column
		
		unless block? pick specs 1 [
			specs: none
		]
		
		;v?? new-items
		
		;new-line/all items true
		
		;vprint length? items
		;v?? columns
		;v?? column
		
		
		
		;items: extract copy/part (at next items column columns) (number-of-lines * columns)
		;items: at items start
		;vprobe items
		;data-list: at data-list start - 1 * columns + 1
		
		; manage font-related stuff
		text-sizer/font: any [font theme-base-font]
		
		chosen: any [chosen []]
		
		;print "--------------------------------------"
		;probe 
		i: 0
		s: none
		itms: copy items
		
		lctx: line-rendering-ctx
		
		lctx/set-defaults compose [
			clipped?: false
			text-color: black
			;width: dimension/x
			bg-color: none
		]
		lctx/font: any [font theme-base-font]
		lctx/width: dimension/x

		text-sizer/size: 10000x100
		text-sizer/para/wrap?: false
		text-sizer/edge:  none
		text-sizer/font/offset: 0x0
		text-sizer/para/origin: 0x0
		text-sizer/para/margin: 0x0


		font-align: lctx/font/align
		lctx/font/align: 'left
		;lctx/font/valign: 'top

pos-mem: position
		unless empty? itms [
			insert tail blk reduce [
				'font font 
				'line-width 0 
				pen (red) 
				fill-pen (blue)
			]
			until [
				i: i + 1
				t: take itms
				if specs [
					s: take specs
				]
				lctx/reset
				if s [ apply-spec lctx s	]
				
				;lctx/edge-color: ( random white) + gray 
				if any [
					;odd? i
					lctx/bg-color
					lctx/edge-color
				][
					;lctx/bg-color: any [lctx/bg-color white]
					;if odd? i [lctx/bg-color: lctx/bg-color - 20.20.20]
					insert tail blk compose [
						pen (lctx/edge-color)
						fill-pen (lctx/bg-color)
						box (position + 0x1) (position + line-height + (dimension * 1x0))
					]
				]
				if t [
					lctx/text: copy t
					
					clip-string lctx

					; manage spaces at head
					spaces: 0
					parse/all lctx/text [any [#" " (spaces: spaces + 1) | thru end]]
					;?? spaces
					
					insert tail blk compose [line-width 0 fill-pen (lctx/text-color) pen none]
					insert tail blk 'text
					insert tail blk position + (1x0 * lctx/indent) + (leading / 2 * 0x1 + 2x-1) + (spaces  * font/size / 2 * 1x0)
					insert tail blk trim lctx/text
					insert tail blk 'vectorial



;				if all [length arrows][
;					text-sizer/text: text
;					;arrow-offset: size-text text-sizer 
;					arrow-offset: dimension/x  - 2
;					
;					insert tail blk compose [pen 255.255.255.125 fill-pen 255.255.255.50 ]
;					insert tail blk prim-arrow (arrow-offset * 1x0 + position + (line-height / 2) + 3x1 ) 13x10 'bullet 'right
;					
;					insert tail blk compose [ pen 0.0.0.150 fill-pen 0.0.0.200 ]
;					insert tail blk prim-arrow (arrow-offset * 1x0 + position + (line-height / 2) + 2x1 ) 6x7 'bullet 'right
;					
;					insert tail blk compose [pen (pen) fill-pen (fill-pen) ]
;				]
				




				]
				
				;---
				; increment position even if no text at current list item.
				position: position + line-height
				
				
				any [
					tail? itms
					position/y + line-height/y > end/y 
;					[
;						;---
;						; just in case our previous calculations where off.
;						print position/y + line-height/y
;						print position/y
;						print line-height/y
;						print end/y
;						print "OOPS !!!"
;						probe length? itms
;						ask "~~"
;						itms: tail itms
;					]
				]
				
			]
		]
		;print "----"


		
position: pos-mem
		; accumulate list to draw, 
		clip-strings list: items  dimension  font
		;probe list
		unless empty? list [
			insert tail blk reduce ['font font 'line-width 0 pen (pen) fill-pen (fill-pen)]
			until [
				label: first list
				length: second list
				text: either length [
					either arrows [
						text: copy/part label (length - 1)
					][
						text: copy/part label (length )
					]
				][label]
				;insert tail blk [box -1x-1 -1x-1]
				; convert leading spaces to pos offset (cures a BAD rendering bug with text)
				
;				spaces: 0
;				parse/all label [any [#" " (spaces: spaces + 1) | thru end]]
;				;?? spaces
;				
;				insert tail blk 'text
;				insert tail blk position + (leading / 2 * 0x1 + 2x-1) + (spaces  * font/size / 2 * 1x0)
;				insert tail blk trim/head copy text
;				insert tail blk 'vectorial
;				
;				if all [length arrows][
;					text-sizer/text: text
;					;arrow-offset: size-text text-sizer 
;					arrow-offset: dimension/x  - 2
;					
;					insert tail blk compose [pen 255.255.255.125 fill-pen 255.255.255.50 ]
;					insert tail blk prim-arrow (arrow-offset * 1x0 + position + (line-height / 2) + 3x1 ) 13x10 'bullet 'right
;					
;					insert tail blk compose [ pen 0.0.0.150 fill-pen 0.0.0.200 ]
;					insert tail blk prim-arrow (arrow-offset * 1x0 + position + (line-height / 2) + 2x1 ) 6x7 'bullet 'right
;					
;					insert tail blk compose [pen (pen) fill-pen (fill-pen) ]
;				]
				
				either find-same chosen label [
					unless highlight-start [
						highlight-start: position - 1x0
					]
				][
					if highlight-start [
						; add a glass effect to selection, spans multiple items!
						insert tail blk prim-glass highlight-start  (position + (dimension/x * 1x0) + 1x1) theme-glass-color theme-glass-transparency
						insert tail blk compose [pen (pen) fill-pen (fill-pen) ]
					]
					highlight-start: none
				]
				
				; increments
				position: position + line-height
				if position/y + line-height/y > end/y [
					list: tail list
				]
				
				; end condition
				tail? list: next next list
			]
			
			; make sure we add tail of selection if it goes past visible list.
			if highlight-start [
				; add a glass effect to selection, spans multiple items!
				insert tail blk prim-glass highlight-start  (position + (dimension/x * 1x0) + 1x1) theme-glass-color theme-glass-transparency
				insert tail blk compose [pen (pen) fill-pen (fill-pen) ]
			]
			
		]
		vout
		blk
	]
	
	
	;-----------------
	;-    prim-item-stack()
	;
	; returns a block: [ size [AGG block]]
	;-----------------
	prim-item-stack: func [
		p [pair!] "position"
		items [block!] ; flat block of label/value pairs.
		columns [integer!] ; 2 by default
		font [object!]
		leading [integer!]
		orientation [word!]
		/local line-size blk size
	][
		vin [{prim-item-stack()}]
		line-size: font/size + leading * 0x1
		text-sizer/font: font


		blk: compose [
			
			font (font)
		]
		items: extract items columns

		size: 0x0

		foreach item items [
			append blk compose [
				text (p) (item) vectorial
			]
			p: p + line-size
			text-sizer/text: item
			size: p + second size-text text-sizer
		]
			
		vout
		reduce [size blk]
	]
	
	
	
	
	;-----------------
	;-    prim-arrow()
	;
	; notes:
	;    -dimension will affect scale and length depending on types.
	;     usually the perpendicular length is scale
	;    -orientation doesn't rotate dimension.
	;    -position is tip of arrow
	;    -for best results dimension should be an odd number
	;    -no color or vector parameter is supplied here, set that up before calling the primitive.
	;-----------------
	prim-arrow: func [
		position [pair!]
		dimension [pair!] "x: length of shaft, if any.  y: scale" ; when x = y, arrowhead is equilateral.
		type [word!] "one of: opened closed bullet broad"
		orientation [word!] "one of:  up down left right"
		/local top bottom size blk
	][
		vin [{prim-arrow()}]
		; arrow tip is at 0x0
		top: (dimension/y / 2) * 0x-1  +  ( dimension/x * 0.7 * -1x0 ) 
		bottom: (dimension/y / 2) * 0x1 + ( dimension/x * 0.7 * -1x0 )
		
		;?? position
		;?? top
		;?? bottom
		
		blk: switch type [
			; -->
			shaft [
				
			]
			
			; --|>
			closed
			[
				
			]
			
			; |>
			bullet [
				switch orientation  [
					right [
						compose/deep [
							push [
								translate (position)
								polygon (0x0) (top) (bottom)
							]
						]
					]
					down [
						
						compose/deep [
							push [
								translate (position)
								rotate 90
								polygon (0x0) (top) (bottom)
							]
						]
					]
				]
			]
			
			; >
			broad [
			
			]
			
		]
		v?? blk
		vout
		blk
	]
	


	;--------------------------
	;-    prim-drop-shadow()
	;--------------------------
	; purpose:  adds a drop shadow around a square region
	;
	; notes:    only returns the draw block, you must still render it 
	;
	; to do:    add theme controls
	;--------------------------
	prim-drop-shadow: funcl [
		position [pair!]
		dimension [pair!]
		corner [integer!]
	][
		;vin "prim-drop-shadow()"
		end: position + dimension
		blk: compose [
			fill-pen none
			pen 0.0.0.200
			box (position - 1x1) (end + 1x1) (corner + 1)
			pen  0.0.0.227
			box (position - 2x2) (end + 2x2) (corner + 2)
			pen  0.0.0.245
			box (position - 3x3) (end + 3x3) (corner + 3)
			pen  0.0.0.250
			box (position - 4x4) (end + 4x4) (corner + 4)
		]
		
		;vout
		blk
	]

	
	
	;-----------------
	;-    prim-knob()
	;-----------------
	prim-knob: func [
		position [pair!]
		dimension [pair!] ; does NOT do - 1x1 automatically
		color [tuple! none!]
		border-color [tuple! none!]
		orientation [word!] ; 'vertical | 'horizontal
		shadow [integer! none!]
		corner [integer!]
		/highlight "Use default highlight method"
		/grit "add a little bit of texture at the center of knob (follows orientation)"
		/local blk e pos width
	][
		vin [{prim-knob()}]

		color: any [color theme-knob-color]
		;color: red
		;border-color: any [border-color theme-knob-border-color]
		
		shadow: any [shadow 0]
		if shadow <> 0 [
			shadow: shadow + 1
		]
		
		;?? shadow
		
		; bug in draw...
		
		
		
		blk: compose either orientation = 'vertical [
			[
				(
					either 0 = shadow [[]][
						compose [
							; shadow
							pen none
							fill-pen linear ( e: (position + (dimension * 0x1) + 1x1)) 1 (5) 90 1 1 
								(0.0.0.180) 
								(0.0.0.240) 
								(0.0.0.255 )
							box (e + -1x-6) (e + (dimension * 1x0) + 0x4) (corner)
						]
					]
				)

				(
					; bug in AGG, when pen is none or color, objects have a different overall size by 1x1
					if border-color = none [
						dimension: dimension + 1x1
					]
					[]
				)

				; bg
				line-width 1
				pen (border-color)
				;fill-pen linear (position) 1 (dimension/x) 0 1 1 ( color * 0.8 + (white * .2)) ( color ) (color * 0.9 )
				fill-pen ( color * 0.8 + (white * .2))
				box (position) (position + dimension) (corner - 1)
				
				; shine
				fill-pen 255.255.255.170
				pen none
				box (position + 1x1) (position + (dimension * 1x0 / 2) + (dimension * 0x1)  ) (corner)
				
				
				(
					either grit [
						pos: position + (dimension / 2 * 0x1) + 3x0
						width: dimension * 1x0 - 6x0
						compose [
							line-width 1
							pen 0.0.0.200
							line (pos) (pos + width)
							line (pos + 0x3) (pos + width + 0x3)
							line (pos - 0x3) (pos + width - 0x3)
							pen 255.255.255.50
							line (pos + 0x1) (pos + width + 0x1)
							line (pos + 0x4) (pos + width + 0x4)
							line (pos - 0x2) (pos + width - 0x2)
						]
					][[]]
				)
				
			]
		][
			[
				(
					either 0 = shadow [[]][
						compose [
							; shadow
							pen none
;							fill-pen linear ( e: (position + (dimension * 0x1) + 1x1)) 1 (2) 90 1 1 
;								(0.0.0.190) 
;								(0.0.0.243) 
;								(0.0.0.255 )
							;fill-pen (red)
							;box (e + -1x-6) (e + (dimension * 1x0) + 0x2) (corner)
							(prim-drop-shadow position dimension corner)
						]
					]
				)

				(
					; bug in AGG, when pen is none or color, objects have a different overall size by 1x1
					if border-color = none [
						dimension: dimension + 1x1
					]
					[]
				)

				; bg
				line-width 0
				pen (border-color)
				fill-pen linear (position) 1 (dimension/y) 90 1 1 ( color * 0.8 + (white * .2)) ( color ) (color * 0.9 )
				;fill-pen ( color * 0.8 + (white * .2))
				box (position) (position + dimension) (corner - 1)
				
				; shine
				fill-pen 255.255.255.170
				pen none
				box (position + 1x1) (position + (dimension * 0x1 / 2) + (dimension * 1x0)  ) (corner)
				
				
				(
					either grit [
						pos: position + (dimension / 2 * 1x0) + 0x3
						width: dimension * 0x1 - 0x6
						compose [
							line-width 1
							pen 0.0.0.200
							line (pos) (pos + width)
							line (pos + 3x0) (pos + width + 3x0)
							line (pos - 3x0) (pos + width - 3x0)
							pen 255.255.255.50
							line (pos + 1x0) (pos + width + 1x0)
							line (pos + 4x0) (pos + width + 4x0)
							line (pos - 2x0) (pos + width - 2x0)
						]
					][[]]
				)
				
			]
		]
		
		
		vout
		
		; we just this word to save some word binding.
		blk
	]



	if rebol-version < 20708 [
		; makes prim-knob safer with older versions of rebol which have troubles with too many gradients and texts
		;-----------------
		;-    prim-knob() v 2.7.6
		;-----------------
		prim-knob: func [
			position [pair!]
			dimension [pair!] ; does NOT do - 1x1 automatically
			color [tuple! none!]
			border-color [tuple! none!]
			orientation [word!] ; 'vertical | 'horizontal
			shadow [integer! none!]
			corner [integer!]
			/highlight "Use default highlight method"
			/grit "add a little bit of texture at the center of knob (follows orientation)"
			/local blk e pos width
		][
			vin [{prim-knob()}]
	
			color: any [color theme-knob-color]
			;color: red
			;border-color: any [border-color theme-knob-border-color]
			
			shadow: any [shadow 0]
			if shadow <> 0 [
				shadow: shadow + 1
			]
			
			;?? shadow
			
			; bug in draw...
			
			
			
			blk: compose either orientation = 'vertical [
				[
	;				(
	;					either 0 = shadow [[]][
	;						compose [
	;							; shadow
	;							pen none
	;							fill-pen linear ( e: (position + (dimension * 0x1) + 1x1)) 1 (4) 90 1 1 
	;								(0.0.0.180) 
	;								(0.0.0.240) 
	;								(0.0.0.255 )
	;							box (e + -1x-6) (e + (dimension * 1x0) + 0x3) (corner)
	;						]
	;					]
	;				)
	
					(
						; bug in AGG, when pen is none or color, objects have a different overall size by 1x1
						if border-color = none [
							dimension: dimension + 1x1
						]
						[]
					)
	
					; bg
					line-width 1
					pen (border-color)
					;fill-pen linear (position) 1 (dimension/x) 0 1 1 ( color * 0.8 + (white * .2)) ( color ) (color * 0.9 )
					fill-pen ( color * 0.8 + (white * .2))
					box (position) (position + dimension) (corner - 1)
					
					; shine
					fill-pen 255.255.255.170
					pen none
					box (position + 1x1) (position + (dimension * 1x0 / 2) + (dimension * 0x1)  ) (corner)
					
					
					(
						either grit [
							pos: position + (dimension / 2 * 0x1) + 3x0
							width: dimension * 1x0 - 6x0
							compose [
								line-width 1
								pen 0.0.0.200
								line (pos) (pos + width)
								line (pos + 0x3) (pos + width + 0x3)
								line (pos - 0x3) (pos + width - 0x3)
								pen 255.255.255.50
								line (pos + 0x1) (pos + width + 0x1)
								line (pos + 0x4) (pos + width + 0x4)
								line (pos - 0x2) (pos + width - 0x2)
							]
						][[]]
					)
					
				]
			][
				[
	;				(
	;					either 0 = shadow [[]][
	;						compose [
	;							; shadow
	;							pen none
	;							fill-pen linear ( e: (position + (dimension * 0x1) + 1x1)) 1 (4) 90 1 1 
	;								(0.0.0.180) 
	;								(0.0.0.240) 
	;								(0.0.0.255 )
	;							box (e + -1x-6) (e + (dimension * 1x0) + 0x3) (corner)
	;						]
	;					]
	;				)
	
					(
						; bug in AGG, when pen is none or color, objects have a different overall size by 1x1
						if border-color = none [
							dimension: dimension + 1x1
						]
						[]
					)
	
					; bg
					line-width 0
					pen (border-color)
					;fill-pen linear (position) 1 (dimension/y) 90 1 1 ( color * 0.8 + (white * .2)) ( color ) (color * 0.9 )
					fill-pen ( color * 0.8 + (white * .2))
					box (position) (position + dimension) (corner - 1)
					
					; shine
					fill-pen 255.255.255.170
					pen none
					box (position + 1x1) (position + (dimension * 0x1 / 2) + (dimension * 1x0)  ) (corner)
					
					
					(
						either grit [
							pos: position + (dimension / 2 * 1x0) + 0x3
							width: dimension * 0x1 - 0x6
							compose [
								line-width 1
								pen 0.0.0.200
								line (pos) (pos + width)
								line (pos + 3x0) (pos + width + 3x0)
								line (pos - 3x0) (pos + width - 3x0)
								pen 255.255.255.50
								line (pos + 1x0) (pos + width + 1x0)
								line (pos + 4x0) (pos + width + 4x0)
								line (pos - 2x0) (pos + width - 2x0)
							]
						][[]]
					)
					
				]
			]
			
			
			vout
			
			; we just this word to save some word binding.
			blk
		]	
	]
	
	





	
	;-----------------
	;-    prim-recess()
	;
	; a depression from bg using a slight gradient fill
	;-----------------
	prim-recess: func [
		position [pair!]
		dimension [pair!] ; does NOT do - 1x1 automatically
		color [tuple! none!]
		border-color [tuple! none!]
		orientation [word!] ; 'vertical | 'horizontal
		/highlight "Use default highlight method"
		/local blk
	][
		vin [{prim-recess()}]

		color: any [color theme-recess-color]
		;border-color: any [border-color theme-edge-color]
		
		blk: compose either orientation = 'vertical [
			[
				line-width 1
				pen border-color
				fill-pen linear (position) 1 (dimension/x) 0 1 1  (color * 0.9 ) ( color ) ( color * 0.8 + (white * .2))
				box (position) (position + dimension) 3
				
;				fill-pen 255.255.255.150
;				pen none
;				box (position + 1x1) (position + (dimension * 1x0 / 2) + (dimension * 0x1) ) 3
			]
		][
		
			[
				line-width 1
				pen border-color
				fill-pen linear (position) 1 (dimension/y) 90 1 1  (color * 0.9 ) ( color ) ( color * 0.8 + (white * .2))
				box (position) (position + dimension) 3
			]
		]
		
		
		vout
		
		; we just this word to save some word binding.
		blk
	]
	
	
	;-----------------
	;-    prim-cavity()
	;
	; a depression from bg using a slight gradient fill
	;-----------------
	prim-cavity: func [
		p [pair!] "position"
		d [pair!] "dimension" ; does NOT do - 1x1 automatically
		/colors 
			bg  [tuple! none!]
			border [tuple! none!]
		/all "put shadows on all four edges"
		/local blk
	][
		vin [{prim-cavity()}]
		
		blk: compose [
				; bg
				line-width 0
				fill-pen ( bg )
				pen none
				box (p ) (p + d ) 3
		
				; top shadows
				pen none
				fill-pen linear (p + 1x1) 1 (5) 90 1 1 
					(0.0.0.200) 
					(0.0.0.235) 
					(0.0.0.255 )

				box (p + 1x1) (p + (d/x * 1x0) + 0x20) 3

				; left shadows
				fill-pen linear (p + 1x1) 1 (4) 0 1 1 
					(0.0.0.210) 
					(0.0.0.240) 
					(0.0.0.255 )
				box (p + 1x1) (p + (d/y * 0x1) + 4x0) 3
				
				(  either all [
						compose [
							; right shadows
							fill-pen linear (p + d) 1 (4) 180 1 1 
								(0.0.0.210) 
								(0.0.0.240) 
								(0.0.0.255 )
							box (d * 1x0 + p ) (p + d - 4x0) 3
							
							; bottom shadows
							fill-pen linear (p + (d )) 1 (4) 270 1 1 
								(0.0.0.210) 
								(0.0.0.240) 
								(0.0.0.255 )
							;box ( p ) (p + (d * 1x0) - 0x4) 3
							box (p + (0x1 * d) + 0x-4) (p + d) 3
						]
					][[]]
				)
				; edge
				line-width 1
				pen (border)
				fill-pen none
				box (p) (p + d) 3
				
			]
		
		
		vout
		
		; we just this word to save some word binding.
		blk
	]	
	
	
	;-----------------
	;-    prim-shadow-box()
	;
	; a depression from bg using a slight gradient fill
	;-----------------
	prim-shadow-box: func [
		p [pair!] "position"
		d [pair!] "dimension" ; does - 1x1 automatically
		w [integer!] "Shadow width"
		/colors 
			bg  [tuple! none!]
			border [tuple! none!]
		/all "put shadows on all four edges"
		/local 
			o ; offset (w*w)
			s ; start
			e ; end
			r ; right
			b ; bottom
	][
		vin [{prim-shadow-box()}]
		
		
		;d: d - 1x1
		
		o: 1x1 * w
		vo: 0x1 * w
		ho: 1x0 * w 
		s: p + o
		e: p + d 
		se: e + o
		
		sr: (e * 1x0) + (p * 0x1)
		sb: (e * 0x1) + (p * 1x0)
		
		blk: compose [
				
				line-width none
				
				pen none
				
				
;				fill-pen red
;				box (e) (se)
;				
;				fill-pen 255.255.255.128
;				box (sr) (se) 
				
				
				; right shadows
				fill-pen linear (sr + vo) 1 (w) 0 1 1 
					(0.0.0.200) 
					(0.0.0.240) 
					(0.0.0.255 )
				box (sr + vo) (se - vo)


				; bottom shadows
				pen none
				fill-pen linear (sb + ho) 1 (w) 90 1 1 
					(0.0.0.200) 
					(0.0.0.240) 
					(0.0.0.255 )

				box (sb + ho) (se - ho)


				; circular shadow at ends
				
				fill-pen radial (e) 0 (w) 0 1 1
					(0.0.0.200) 
					(0.0.0.240) 
					(0.0.0.255 )
				box (e) (se)

				fill-pen radial (sr + vo) 0 (w) 0 1 1
					(0.0.0.200) 
					(0.0.0.240) 
					(0.0.0.255 )
				box (sr) (sr + o)

				fill-pen radial (sb + ho) 0 (w) 0 1 1
					(0.0.0.200) 
					(0.0.0.240) 
					(0.0.0.255 )
				box (sb) (sb + o)

				; test edge
;				line-width 1
;				fill-pen none
;				pen gold
;				box (p ) (se) (w)
				
				
				
				
				
		
;				; top shadows
;				pen none
;				fill-pen linear (p + 1x1) 1 (5) 90 1 1 
;					(0.0.0.190) 
;					(0.0.0.235) 
;					(0.0.0.255 )
;
;				box (p + 1x1) (p + (d/x * 1x0) + 0x20) 3
;
;				; left shadows
;				fill-pen linear (p + 1x1) 1 (4) 0 1 1 
;					(0.0.0.200) 
;					(0.0.0.240) 
;					(0.0.0.255 )
;				box (p + 1x1) (p + (d/y * 0x1) + 4x0) 3
;				
;				(  either all [
;						compose [
;							; right shadows
;							fill-pen linear (p + d) 1 (4) 180 1 1 
;								(0.0.0.200) 
;								(0.0.0.240) 
;								(0.0.0.255 )
;							box (d * 1x0 + p ) (p + d - 4x0) 3
;							
;							; bottom shadows
;							fill-pen linear (p + (d )) 1 (4) 270 1 1 
;								(0.0.0.200) 
;								(0.0.0.240) 
;								(0.0.0.255 )
;							;box ( p ) (p + (d * 1x0) - 0x4) 3
;							box (p + (0x1 * d) + 0x-4) (p + d) 3
;						]
;					][[]]
;				)
;				; edge
;				line-width 1
;				pen (border)
;				fill-pen none
;				box (p) (p + d) 3
;				
			]
		
		
		vout
		
		; we just this word to save some word binding.
		blk
	]	

	
;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- LOW-LEVEL GLASS FUNCS
;
;-----------------------------------------------------------------------------------------------------------
	;-     layout()
	;-----------------
	; this is used to construct whole interfaces, based on a static specification.
	;
	; eventually, you will be able to generate SEVERAL WINDOWS at once!
	;
	; this is the basic entry point for SHINE (the Glass dialect)
	;
	; if within is specified, the spec will be applied to it.  any new marbles are ADDED to the frame
	; the only requirement is that the /within marble MUST be a frame.
	;
	; the layout func was move here since some marbles will need layout in their initialization.
	;-----------------
	layout: func [
		spec [block!]
		/within wrapper [word! object! none!] "a style name or an actual allocated marble, inside of which we will put new marbles."
		/using stylesheet [block!]
		/options wrapper-spec [block!] "allows you to supply a spec used when creating the wrapper itself."
		/position offset [pair!] "You can set the offset value of the wrapper. this allows you to manually place the window"
		/only "do not automatically open a window if a !window is the wrapper (which it is by default)"
		/size sz [pair! decimal!] "when decimal! its a scale of the screen-size."
		/center
		/tight "adds or creates a 'tight option to wrapper spec without need for options block."
		/local style guiface bx draw-spec filling wrap?
	][
		vin [{layout()}]
		vprobe spec
		
		
		; normalize stylesheet
		stylesheet: any [stylesheet master-stylesheet]
		
		
		;-------------------------
		; manage the wrapper
		;---
		; do we create a new top frame, or use specified wrapper and ADD new spec to it?
		switch type?/word wrapper [
;			object! [
;				; USE TOP MARBLE AS-IS
;				;within: wrapper
;			]
			
			word! none! [
				; either user specified or system default wrapper (eventually, default will be a 'window)
				style: any [wrapper 'window]
				
				; make sure the wrapper style exists.
				unless wrapper: select stylesheet style [
					to-error rejoin ["" style " type NOT specified in stylesheet"]
				]
				
				if all [
					style = 'window
					none? wrapper-spec
				][
					wrapper-spec: [tight]
				]
					
				
				; allocate a new wrapper.
				wrapper: alloc-marble/using wrapper wrapper-spec stylesheet
				wrap?: true
			]
		]
		
		
		;-------------------------
		; create the GUI
		;----
		; note that any item in the spec which precedes a marble name, will *eventually* be
		; used by the wrapper/gl-specify(), so you can set it up directly without needing to add special
		; refinements to layout.  :-)
		spec: reduce [spec]
		
		either wrap? [
			wrapper/valve/gl-specify/wrapper wrapper spec stylesheet
			wrapper/valve/gl-fasten wrapper

			; setup glob so it returns its draw block
			wrapper/glob/valve/reflect wrapper/glob [2 ]
		][
			wrapper/valve/gl-specify wrapper spec stylesheet
			wrapper/valve/gl-fasten wrapper
		]
		
		; if the wrapper is a window viewport, we automatically call its show.
		; this is the default layout mechanism.
		;
		; if you specify /only, we forego this step, and expect the application
		; to call its display method later on.
		
		if size [
			switch type?/word sz [
				pair! [
					fill* wrapper/material/dimension sz
				]
				decimal! [
					;probe screen-size
					fill* wrapper/material/dimension screen-size * sz
				]	
			]
		]
		
		if offset [
			fill* wrapper/aspects/offset offset
		]
		
		
		if all [
			not only
			in wrapper 'display
			in wrapper 'hide
		][
			vprint "I WILL DISPLAY WINDOW!!!"
			
			either center [
				wrapper/display/center
			][
				wrapper/display
			]
		]
		
		
		
		vout
		wrapper
	]

	;-----------------
	;-     alloc-marble()
	;-----------------
	alloc-marble: func [
		style [word! object!] "Specifying an object expects any marble, from which it will clone itself, a word is used to lookup a style from a stylesheet"
		spec [block! none!]
		/using stylesheet [block! none!] "specify a stylesheet manually"
		/local marble
	][
		vin [{sillica/alloc-marble()}]
		stylesheet: any [stylesheet master-stylesheet]
		
		; resolve reference marble to use as the style basis.
		unless object? style [
			; make sure the wrapper type exists.
			unless marble: select stylesheet style [
				to-error rejoin ["" style " not in stylesheet"]
			]
			style: marble
		]
		
		; make sure the style really is a glass marble
		either all [
			object? style
			in style 'valve
			in style/valve 'style-name
		][
			; create the new marble instance 
			vprint "------ CREATE marble ------"
			marble: liquify* style
			
			vprint "------ SPECIFY marble ------"
			if spec [
				; spec might create inner marbles if the style is a group type marble and spec contains marbles.
				;
				; SPECIFY CAN MANIPULATE AND EVEN REPLACE THE SUPPLIED MARBLE... do not expect
				; the return marble to be the same as the one we supply to gl-specify.
				;
				gbl-mrbl: marble
				marble: marble/valve/gl-specify marble spec stylesheet		
				;unless same? gbl-mrbl marble [
				;	probe "AHA"
				;	halt
				;]
			]
			
		][
			to-error "Invalid reference style... not a glass marble!"
		]
		
		; cleanup GC
		style: spec: stylesheet: none
		
		vout
		marble
	]
	

	
	;-----------------
	;-     get-aspect()
	;-----------------
	get-aspect: func [
		marble
		item
		/or-material "this will also any material instead, if it exists"
		/plug "only return the plug of the aspect, not its value"
		/local p
	][
		vin [{get-aspect()}]
		vout
	
		all [
			any [
				; materials have precedence!
				if or-material [p: in marble/material item]
				p: in marble/aspects item
			]
			p: get p
			either plug [
				all [
					object? p
					in p 'valve ; is this really a plug?
					p
				]
			][
				content* p
			]
		]
		
	]
	
	
	
	
	
;-                                                                                                       .
;-----------------------------------------------------------------------------------------------------------
;
;- LAYOUT HELPERS
;
;-----------------------------------------------------------------------------------------------------------
	
	;-----------------
	;-     relative-marble?()
	; returns true if the supplied marble meets the conditions for managed relative positioning.
	;
	; basically, the marble needs an offset and a position material.
	;
	; the other prefered setup is that the position is within the aspect directly, and its not in the material.
	; which indicates that you are using absolute positioning.
	;-----------------
	relative-marble?: func [
		marble [object!]
		/true?
	][
		vin [{glass/relative-marble?()}]
		
		true?: all [
			in marble/aspects 'offset
			in marble/material 'position
			true
		]
		vout
		
		true?
	]
	

	;----------------------
	;-     wrap-lines()
	;
	; this is a VERY fast function, can be used within area or field type styles
	;----------------------
	wrap-lines: func [
		"Returns a block with a face's text, split up according to how it currently word-wraps."
		face "Face to scan.  It needs to have text, a size and a font"
		/local txti counter text
	][

		counter: 0
		txti: make system/view/line-info []
		while [textinfo face txti counter ] [
			counter: counter + 1
		]

		; free memory & return
		txti: none
		counter
	]

	
	
	;-----------------
	;-     sub-box()
	; returns a box which is a fraction of another box, using /orientation will
	; scale one of the coordinates to 100%
	;
	; min max are used to define the denominator of the fraction, amount is used to define
	; the numerator of the fraction
	;-----------------
	sub-box: func [
		box [pair!] 
		min [number!] "zero-based value"
		max [number!] "zero-based value"
		amount [number!] "zero-based value"
		/index "amount is an index within the range, instead of the visible part of range"
		/orientation ori [word! none!] "orientation of the box"
		/local range sub
	][
		;vin [{sub-box()}]
		
		
		;?? box
		;?? min
		;?? max
		;?? amount
		;?? ori
		range: max - min
		
		;?? range
		if index [
			amount: max 0 amount - min
		]
		scale: min* 1 any [
			all [range = 0 0]
			amount / range
		]
		
		;?? scale
		
		sub: switch/default ori [
			horizontal [
				;print "horizontal"
				;print box * scale
				max* (box * scale) (0x1 * box)
			]
			
			vertical [
				max* (box * scale) (1x0 * box)
			]
		][
			box * scale
		]
		
		;?? sub
		
		;vout
		sub
	]
	
	
	
	;-----------------
	;-     screen-size()
	;-----------------
	screen-size: func [
	][
		system/view/screen-face/size
	]
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- STYLE MANAGEMENT
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;-----------------
	;-     collect-style()
	;-----------------
	; adds a marble style to a stylesheet, by default this is the master-stylesheet
	;-----------------
	collect-style: func [
		marble [object!]
		/into stylesheet [block!]
		/as style-name "this is actually encouraged, enforces style unicity"
		/local s old
	][
		vin [{glass/collect-style()}]
		vprint marble/valve/style-name
		
		s: any [stylesheet master-stylesheet]
		
		style-name: any [style-name marble/valve/style-name]
		
		; this is required to properly separate styles as separate entities completely.
		; not doing this allows quickly generated derivatives to share the valve, which isn't
		; very safe.  it could actually cause a derivative to highjack another style's 
		; valve.
		;
		; this may lead to dirty side-effect for inexperienced style creators.
		if as [
			marble: make marble [valve: make valve [] ]
			marble/valve/style-name: style-name
		]
		
		; add or replace style?
		if old: find s style-name [
			vprint "replacing old-style"
			remove/part old 2
		]
		append s style-name 
		append s marble
		
		s: stylesheet: old: none
		vout
		marble
	]
	
	
	;-----------------
	;-     list-stylesheet()
	;-----------------
	; simple abstraction for listing all styles in a stylesheet
	list-stylesheet: func [
		/using stylesheet [block! none!]
		/local rval
	][
		vin [{glass/list-stylesheet()}]
		stylesheet: any [stylesheet master-stylesheet]
		rval: extract stylesheet 2
		stylesheet: none
		vout
		
		rval
	]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GUI SPEC MANAGEMENT
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;-----------------
	;-    regroup-specification()
	; take a spec block and break it up according to style names
	;
	; if items precede any recognized style name, they will be included at the root level of the returned spec.
	;-----------------
	regroup-specification: func [
		spec
		/using stylesheet [block!]
		/local s list gspec marble mode style-name set-word
	][
		vin [{glass/regroup-specification()}]
		s: any [stylesheet master-stylesheet]
		list: list-stylesheet/using stylesheet
		
		;?? list
		
		; create new grouped spec
		gspec: copy []
		marble: gspec
		
		; traverse all spec
		while [not empty? spec] [
			;item: first spec
			;print "--------------"
			;probe pick spec 1
			
			mode: none
			; is this a style name?
			mode: any [
				all [
					set-word? set-word: pick spec 1
					word? style-name: pick spec 2
					find list style-name
					'set-marble
				]
				all [
					word? style-name: pick spec 1
					find list style-name
					'marble
				]
			]
			;print mode
			switch/all mode [
				marble set-marble [
					; new marble starts here, create a new marble spec
					marble: copy []
					append/only gspec marble
				]
				set-marble [
					append/only marble pick spec 1
					spec: next spec
				]
			]
			append/only marble pick spec 1
			spec: next spec
		]
		
		s: marble: old: none
		vout
		gspec
	]
	

]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

