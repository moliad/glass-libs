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



;- ;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'glass
;
;--------------------------------------

slim/register [
	;- LIBS
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

	
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection !pin]
	
	;- EVENT MANAGEMENT OVERHAUL
	event-lib: slim/open 'event none
	
	;- load default stylesheet
	glaze-lib: slim/open 'glaze none
	glue-lib: slim/open 'glue none
	
	
	
	
	;--------------------------------------------------------
	;-   
	;- HIGH-LEVEL API
	;
	;-----------------



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
		title [string!]
		viewport [object! none!] "be carefull giving a none! here, last opened window MUST BE A GLASS WINDOW"
		req [object! block!]
		/non-blocking "Do not trigger input blocker"
		/modal
		/size sz [pair!]
		/local trigger 
	][
		vin [{glass/request()}]
		
		if block? req [
			req: layout/within/options req 'requestor reduce [title]
		]
		
		fasten req

		viewport: any [viewport default-viewport]
		
		req/viewport: viewport
		
		trigger: any [
			all [non-blocking 'ignore]
			all [modal 'ignore]
			'remove
		]
		
		pin req viewport 'center 'center
		
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
	
	
	
	;-----------------
	;-     hide-request()
	;-----------------
	hide-request: func [
		req [object! none!]
		/local viewport
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
	
	
	
	;- REQUESTORS
	;-----------------
	;-     request-string()
	;-----------------
	request-string: func [
		title [string!]
		/local fld rval
	][
		vin [{request-string()}]
		request/modal title none [
			column 20x10 [
				fld: field 200x23
			]
			row [
				hstretch
				button 75x23 stiff "Ok" [rval: content* fld/aspects/label hide-request none resume]
				button 75x23 stiff "Cancel" [hide-request none resume ]
			]
			do [print "444444444444444444444444444444444444444"]
		]
		vout
		rval
	]
	
	
	
	;-----------------
	;-     request-confirmation()
	;-----------------
	request-confirmation: func [
		title [string!]
		/message msg [string!]
		/labels lbl-ok [string!] lbl-cancel [string!]
		/local rval 
	][
		vin [{request-confirmation()}]
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
	
	
	
	;- EVENT-LIB RELATED STUFF
	
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
		vp [object!]
	][
		vin [{refresh()}]
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
		marble [object! block! word!]
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
	
	
	
	;- FOCUS control
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
	;-----------------
	unfocus: func [
		marble
	][
		vin [{unfocus()}]
		if window: search-parent-frames marble 'window [
			window: last window
			event-lib/queue-event compose [
				action: 'unfocus 
				marble: (marble)
				view-window: window/view-face
			]
		]
		vout
	]
	
	
	
	
	
	;- OTHER

	
	;-----------------
	;-     search-parent-frames()
	;
	; <TO DO> support block! input
	;
	; returns first parent with valve/style-name set in criteria
	;-----------------
	search-parent-frames: func [
		marble [object!]
		criteria [string! integer! issue! word! tuple!]
		/id "searches usr-id in frames"
		/local frm rdata
	][
		vin [{glass/search-paren-frames()}]
		if frm: marble/frame [
			case [
				id [
					until [
						if frm/user-id = criteria [
							append any [rdata rdata: copy []] frm
						]
						none? frm: frm/frame
					]
				]
				
				true [
					criteria: to-word to-string criteria
					until [
						if frm/valve/style-name = criteria [
							append any [rdata rdata: copy []] frm
						]
						none? frm: frm/frame
					]
				]
			]
		]
		vout
		rdata
	]
	
	
			



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

