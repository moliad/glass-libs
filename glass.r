REBOL [
	; -- Core Header attributes --
	title: "Glass main library"
	file: %glass.r
	version: 1.0.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: {GLASS - Graphical user interface engine high-level api.}
	web: http://www.revault.org/modules/glass.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'glass
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/glass.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

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
		v1.0.0 - 2013-09-17
			-License changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: {
		This library acts as a single entry point for the whole GLASS gui framework.
		
		As such it defines mostly stubs to lower-level features and libraries.
		
		When something is defined here it is best to use it as opposed to using the other modules directly.
		This is meant as the most stable reference for the whole engine, and will stay backwards compatible
		as much as is possible.
		
		There are also a few useful functions here which implement unobvious little tricks within
		GLASS, like the refresh() function which forces a refresh within the event stream.
	}
	;-  \ documentation
]



 
;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'glass
;
;--------------------------------------

slim/register [
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
	]
	
	sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		layout
		screen-size
	]
	
	slim/open/expose 'glass-core-utils none [  search-parent-frames   ]
	
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection !pin]
	event-lib: slim/open 'event none
	glaze-lib: slim/open 'glaze none
	glue-lib: slim/open 'glue none
	
	
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- HIGH-LEVEL API
	;
	;-----------------------------------------------------------------------------------------------------------
		



	;-----------------
	;-     set-aspect()
	;
	; API stub for marble's internal set-aspect function.
	;
	; returns true or false if assignment was possible or not.
	;-----------------
	set-aspect: func [
		marble [object!]
		aspect [word!]
		value 
	][
		vin [{glass/set-aspect()}]
		value: marble/valve/set-aspect marble aspect value
		vout
		value
	]
			
	

	;-----------------
	;-     request()
	;
	; adds a requestor to the overlay, triggers input blocker
	;
	; if overlay is a block, layout is called on it directly.
	;-----------------
	request: func [
		title [string! none!] "when title is none, we don't use the requestor style."
		viewport [object! none!] "be carefull giving a none! here, last opened window MUST BE A GLASS WINDOW"
		req [object! block!]
		/non-blocking "Do not trigger input blocker"
		/modal
		/size sz [pair!]
		/position pos [pair! object!] "when given an object, it expects a pair! giving plug (can be a marble position material)"
		/local trigger 
	][
		vin [{glass/request()}]
		
		if block? req [
			either title [
				req: layout/within/options req 'requestor reduce [title]
			][
				req: layout/within/options req 'column [tight]
				req: make req [viewport: none]
			]
		]
		
		fasten req

		viewport: any [viewport default-viewport]
		
		req/viewport: viewport
		
		trigger: any [
			all [non-blocking 'ignore]
			all [modal 'ignore]
			'remove
		]
		
		either position [
			; user gave explicit position, put it there.
		][
			pin req viewport 'center 'center
		]
		
		add-overlay req viewport trigger
		
		if size [
			fill* req/material/dimension sz
		]
		
		if modal [
			hold
		]
		
		vout
		req
	]
	

	;--------------------------
	;-     request-popup()
	;--------------------------
	; purpose:  display a popup which disapears when clicked outside of itself.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    does not provide any titlebar, only an edge... with no shadow.
	;
	;           also note that we use a copy of given req object, if supplied a pre built pane object
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	request-popup: funcl [
		marble [object!] "a marble for this popup to be relative to."
		req [block! object!]
		/within viewport "be carefull giving a none! here, last opened window MUST BE A GLASS WINDOW"
		/at at-pos [word!] "a pin orientation (top, bottom, center, top-left, etc)"
		/size sz [pair!]
		/modal
		/slide "slide down the popup like a blind"
	][
		vin "request-popup()"

		slide-pane: none
		slide-frame: none

		if block? req [
			either slide [
				req: compose/deep [
					slide-pane: pane [ slide-frame: ( req )]
				]
				req: layout/within/options req 'column compose [ tight  ]
			][
				req: layout/within/options req 'column compose [ tight  ]
			]
		]
		
		;---
		; just add what the popup managing code needs to track if window has a popup and
		;
		; for event engine to trap it.
		req: make req [
			viewport: none
		]
		fasten req

		viewport: any [viewport default-viewport]
		req/viewport: viewport
		
		trigger: any [
			;all [non-blocking 'ignore]
			all [modal 'ignore]
			'remove
		]
		
		dest-pin: any [at-pos 'bottom-left]
		requestor-pin: 'top-left
		pin req marble requestor-pin dest-pin 
		
		either slide [
			slide-time: .2
		
			unless size [
				sz: content req/material/dimension
			]
			asize: 1x0 * sz 
			
			fill* req/material/dimension asize
			add-overlay req viewport trigger
			
			s: now/precise
			until [
				t: now/precise
				d: to-decimal difference t s
				
				time-fraction: (d / slide-time )
				time-fraction: min time-fraction 1.0
				
				asize: 1x0 * sz 
				asize: ( (time-fraction) * sz * 0x1) + (1x0 * sz)
				
				fill* slide-pane/material/dimension asize
				fill* slide-frame/material/dimension asize
				wait 0.01
				time-fraction > 0.99999
			]
				
			
		][
			if size [
				fill* req/material/dimension sz
			]
			add-overlay req viewport trigger
		]
		
		
		if modal [
			hold
		]
		
		vout
		req		
	]





	;-----------------
	;-     hide-request()
	;-----------------
	hide-request: funcl [
		req [object! none!]
	][
		vin [{glass/hide-request()}]
		
		viewport: any [
			all [
				req 
				req/viewport
			]
			default-viewport
		]
		remove-overlay viewport
		
		vout
	]
	
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- REQUESTORS
	;
	;-----------------------------------------------------------------------------------------------------------

	;-----------------
	;-     request-string()
	;-----------------
	request-string: funcl [
		title [string!]
		/message msg
		/default def-value [string!] "Fill the field with a default value."
	][
		vin [{request-string()}]
		def-value: copy any [def-value ""]
		request/modal title none compose/deep [
			(
				either msg [
					compose [	
						auto-label (msg)
					]
				][
					[]
				]
			)

			column 20x10 [
				fld: field 200x23 (def-value)
			]
			row [
				hstretch
				button 75x23 stiff "Ok" [rval: content* fld/aspects/label hide-request none resume]
				button 75x23 stiff "Cancel" [hide-request none resume ]
			]
			do [print "HAHA"]
		]
		vout
		rval
	]
	
	
	
	;-----------------
	;-     request-confirmation()
	;-----------------
	request-confirmation: funcl [
		title [string!]
		/message msg [string!]
		/labels lbl-ok [string!] lbl-cancel [string!]
	][
		vin [{request-confirmation()}]
		rval: none
		lbl-ok: any [lbl-ok "Ok"]
		lbl-cancel: any [lbl-cancel "Cancel"]
		request/modal title none compose/deep [
			(
				either msg [
					compose [	
						auto-label (msg)
					]
				][
					[]
				]
			)
			row 50x20 [
				hstretch
				button 75x23 stiff (lbl-ok) [rval: true hide-request none resume]
				button 75x23 stiff (lbl-cancel) [hide-request none resume ]
				hstretch
			]
		]
		vout
		rval
	]
	
	
	;--------------------------
	;-     request-action()
	;--------------------------
	; purpose:  build a requestor from scratch with a list of buttons, a title, and a message.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    button values can be functions which are then called like hooks.  these functions may not have any arguments.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	request-action: funcl [
		title [string!]   "Window title"
		message [string!] "Main user message"
		buttons [block!]  {Tag list of button string and button value to return ex: [ "save" 'save  "no save" 'no-save  "cancel" #[none] ] }
		/button-width bw [integer!] "set buttons to this width"
	][
		vin "request-action()"
		rval: none
		spec: copy [
			auto-label (message)
			row 50x20 (btn-spec)
		]
		
		btn-spec: copy [
			hstretch
		]
		foreach [ label value ] buttons [
		
			switch type?/word :value [
				word! lit-word! set-word! get-word! [
					value: compose [ load (mold :value) ]
				]
				
				block! [
					; just wrap it in a block so compose keeps the original block.
					value: append/only copy [  ] value
				]
				
				function! native! [
					; make sure the function has no arguments, otherwise, raise an error.
					if find (spec-of :value) word! [
						to-error "glass/request-action() button function hooks may not have arguments."
					]
				]
				
				routine! operator! [
					to-error "glass/request-action() unsupported types for button values"
				]
			]
			
			;----
			; we keep some values as a string in the button, this cancels the double word evaluation problem
			; we may have with the value resulting from the compose
			;
			; when the requestor is evaluated, we then load back the value.
			;----
			if bw [
				btn-size: (1x0 * bw) + 0x23
			]
			btn-size: any [btn-size 75x23]
			
			append btn-spec compose/deep [
				button (btn-size) stiff (label) [ rval: ( :value ) hide-request none resume ]
			]
		]

		append btn-spec 'hstretch
		spec: compose/only spec
		request/modal title none spec 
		
		vout
		spec: btn-spec: label: value: title: message: buttons: none
		
		rval
	]
	
		
	;-----------------
	;-     request-inform()
	;-----------------
	request-inform: func [
		title [string!]
		/message msg
	][
		vin [{request-inform()}]
		request/modal title none compose/deep [
			(
				either msg [
					compose [	
						auto-label (msg)
					]
				][
					[]
				]
			)
			row 50x20 [
				hstretch
				button 75x23 stiff "Ok" [rval: true hide-request none resume]
				hstretch
			]
		]
		vout
	]
	
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- EVENT-LIB RELATED STUFF
	;
	;-----------------------------------------------------------------------------------------------------------

	
	;-----------------
	;-     hold()
	;
	; stub to event/interrupt to hold the current interpreter until event/resume is used.
	;-----------------
	hold: does [
		event-lib/hold
	]
	
	;-----------------
	;-     resume()
	;
	; stub to event/resume
	;-----------------
	resume: does [
		event-lib/resume
	]
	
	;-----------------
	;-     add-hot-key-handler()
	;-----------------
	add-hot-key-handler: func [
		key
	][
		vin [{add-hot-key-handler()}]
		;append event-lib/hot-keys
		vout
	]
	
	
	
	;-----------------
	;-     refresh()
	;
	; do not call this within event handling as it will enter an endless loop.
	;-----------------
	refresh: func [
		vp [object! none!]
	][
		vin [{refresh()}]
		vp: any [vp default-viewport]
		event-lib/queue-event [action: 'REFRESH viewport: vp]
		
		
		; this forces a refresh immediately and handles all other events too.
		event-lib/do-queue 
		
		;dispatch-event-port	
		
		vout
	]


	
	;-----------------
	;-     add-overlay()
	;-----------------
	add-overlay: func [
		overlay [object!]
		viewport [object!]
		trigr [word! object! block!]
	][
		vin [{add-overlay()}]
		
		; this is required or else queue-event tries to use the word as a variable
		either word? trigr [
			;print "@@@@@@@@@@@@@@@"
			trigr: reduce [to-lit-word trigr]
		][
			trigr: reduce [trigr]
		]
		
		;v?? trigr
		event-lib/queue-event compose/only [
			action: 'add-overlay
			
			; the glob we want to overlay
			frame: overlay
			
			; in what viewport (window?) to show this overlay
			viewport: (viewport)
			
			; the event(s) to trigger when input-blocker is clicked on.
			; note: if this is none, input-blocker is not enabled.
			;
			; if set to 'remove  then the trigger is the default, which
			; simply removes the overlay and disables input-blocker.
			;
			; if set to 'ignore, nothing happens, you'll require some sort
			; of explicit mechanism to call remove-overlay.
			trigger: (first trigr)
			
		]
		vout
	]
	
	

	
	;-----------------
	;-     remove-overlay()
	;-----------------
	remove-overlay: func [
		viewport [object!]
	][
		vin [{remove-overlay()}]
		event-lib/queue-event compose/only [
			action: 'remove-overlay
			
			; in what viewport (window?) to show this overlay
			viewport: (viewport)
		]
		vout
	]
	
	

	
	;-----------------
	;-     pin()
	;
	; pins one marble (offset) according to another marble (offset & dimension).
	; 
	; this function will temporarily enable cycle checks in liquid and restore its previous
	; state on exit.  We do this since its a high-level function and these should not
	; allow a deadlock by default.
	;
	; if you really know what you are doing, you may use the /expert mode which doesn't
	; activate cycle checking.
	;
	; the coordinates are determined using any of:
	; 
	;  center,  
	;  top, T, bottom, B, right, R, left, L
	;  north, N, south, S, east, E, west, W
	;  top-left, TL, top-right, TR, bottom-left, BL, bottom-right, BR
	;  north-west, NW, north-east, NE, south-west, SW, south-east, SE
	;  
	;-----------------
	pin: func [
		marble [object!]
		ref-marble [object!]
		pin-from [word!]
		pin-to [word!]
		/expert "doesn't activate cycle checking, which might slow down operation a lot."
		/offset off [object! pair!] "if its a pair, will fill marble/aspects/offset, on-the-fly"
		/local pin cycle?
	][
		vin [{pin()}]
		pin: marble/material/position
		
		unless expert [
			cycle?: liquid-lib/check-cycle-on-link?
			liquid-lib/check-cycle-on-link?: true
		]
		
		; first we mutate the marble's offset so its a pin node
		pin/valve: !pin/valve

		; then we reset its connection and piping
		unlink*/detach pin
		
		; we fill it with both pin coordinates
		pin/resolve-links?: 'LINK-AFTER
		
		link* pin reduce [
			marble/material/dimension
			ref-marble/material/position
			ref-marble/material/dimension
		]
		fill* pin reduce [pin-from pin-to]
		
		
		
		if pair? off [
			fill* marble/aspects/offset off
			link* pin marble/aspects/offset
		]
		
		if object? off [
			link* pin off
		]
		
		
		unless expert [
			liquid-lib/check-cycle-on-link?: cycle?
		]
		
		vout
	]
	
	
	
	;-----------------
	;-     stretch()
	;-----------------
	stretch: func [
		marble [object!]
		ref-marble [object!]
		size-from [word! none!]
		size-to [word! none!]
		/add s [object! pair!] "if its a pair, will create a plug, on-the-fly"
	][
		vin [{stretch()}]
		vout
	]
	
	
	

	;-----------------
	;-     collect()
	;-----------------
	collect: func [
		frame [object!]
		marble [object!]
		/top
		/only
	][
		vin [{collect-marble()}]
		
		; make sure the marble isn't already in a layout
		unframe marble
		
		either top [
			frame/valve/gl-collect/top frame marble
		][
			frame/valve/gl-collect frame marble
		]
		unless only [
			fasten marble
			fasten frame
		]
		vout
	]
	
	
	
	
	;--------------------------
	;-     surface()
	;--------------------------
	; purpose:  a combination of a discard and a collect, to replace all elements of a frame with a new one.
	;           this is the basis for tab panes, for example.
	;
	; inputs:   a frame and a marble to display into it.   note that the only kind of marble
	;           which cannot be a child of another marble, is the window.  they can only be the children of
	;           screen marbles (not yet designed).
	;
	; returns:  a block with the previous items in the frame's collection.
	;
	; notes:    
	;
	; tests:    
	;--------------------------
	surface: funcl [
		frame [object!]
		marble [object!]
	][
		vin "surface()"
		coll: copy frame/collection
		discard frame 'all
		collect frame marble
		vout
		
		; critical GC cleanup for such a high-level function.
		first reduce [coll coll: none]
	]
	
	
	
	
	;-----------------
	;-     discard()
	;-----------------
	discard: func [
		frame [object!]
		marble [object! block! word!] "you may use 'all as the marble, in which case all marbles are discarded."
		/only
	][
		vin [{collect-marble()}]
		frame/valve/gl-discard frame marble
		unless only [
			fasten frame
		]
		vout
	]
	
	
	
	;--------------------------
	;-     unframe()
	;--------------------------
	; purpose:  like discard, but automatically from its parent.
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    none transparent and 
	;
	; tests:    
	;--------------------------
	unframe: funcl [
		marble [object! none!]
	][
		vin "unframe()"
		if frame: get in marble 'frame [
			discard frame marble
		]
		vout
	]
	
	
	
	;-----------------
	;-     fasten()
	;-----------------
	fasten: func [
		marble [object!]
	][
		vin [{fasten()}]
		marble/valve/gl-fasten marble
		vout
		marble
	]
	
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FOCUS CONTROL
	;
	;-----------------------------------------------------------------------------------------------------------

	;-----------------
	;-    focus()
	;-----------------
	focus: func [
		marble [object!]
		/local window
	][
		vin [{focus()}]
		
		if window: search-parent-frames marble 'window [
			window: last window
			event-lib/queue-event compose [
				action: 'focus 
				marble: (marble)
				view-window: window/view-face
			]
		]
		vout
	]
	
	
	
	;-----------------
	;-    unfocus()
	;
	;
	; inputs:   when supplying a word! we can use 'ALL in which case everything is unfocused.
	;
	;           when supplying an object! it should be a marble which will be sent the unfocus event.
	;
	;           when none! is given, nothing is unfocused.
	;-----------------
	unfocus: func [
		marble [word! object! none!] "what do we unfocus"
	][
		vin [{unfocus()}]
		switch type?/word :marble [
			WORD! [
				;---
				; there could be many other keywords, but they have to be implemented.
				switch/default marble [
					ALL [
						event-lib/queue-event compose [
							action: 'unfocus 
							marble: none
							view-window: none ;window/view-face
						]
						
					]
				][
					vprint "UNKNOWN UNFOCUS KEYWORD"
				]
			]
			
			OBJECT! [
				if window: search-parent-frames marble 'window [
					window: last window
					event-lib/queue-event compose [
						action: 'unfocus 
						marble: (marble)
						view-window: window/view-face
					]
				]
			]
		]
		
		vout
	]
	
	
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- OTHER
	;
	;-----------------------------------------------------------------------------------------------------------


	
			



	;-----------------
	;-     stylesheet-info()
	; display data about a stylesheet
	;-----------------
	stylesheet-info: func [
		/of s "specify a stylesheet to display"
	][
		vin [{stylesheet-info()}]
		s: any [s master-stylesheet]
		s: list-stylesheet/using s
		
		sort s
		
		new-line/all s true
		
		s: mold s
		insert s "styles in stylesheet:^/"
		vprint "styles in stylesheet:"
		vout
		s
	]
	
	
	
	;-----------------
	;-     default-viewport()
	;-----------------
	default-viewport: does [
		get in last system/view/screen-face/pane 'viewport
	]
	
	
	
	;-----------------
	;-     api-von()
	;-----------------
	api-von: func [
		
	][
		vin [{api-von()}]
		event-lib/von
		glue-lib/von
		epoxy-lib/von
		sl/von
		vout
	]
	
	;-----------------
	;-     styles-von()
	;-----------------
	styles-von: func [
	][
		vin [{styles-von()}]
		glaze-lib/styles-von
		vout
	]
	
	
	
	
	
	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

