REBOL [
	; -- Core Header attributes --
	title: "Glass field marble"
	file: %style-field.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: "Text-entry field for GLASS."
	web: http://www.revault.org/modules/style-field.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-field
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-field.r

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
		v0.8.1 - 2013-09-05
			-fixed Cut operation (Ctrl-x)
	
		v1.0.0 - 2013-09-18
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		Glass' Field style is perhaps one of the most advanced fields in any gui package.
		
		its event handling is quite extensive, including support for single, double, tripple clicking,
		scrolling using the mouse wheel and support for "cancel" operations by pressing escape.
		
		using the control key in any state allows per word movement or selection using
		the arrows OR the scrollwheel.
		
		using up or down simulates pressing control.
		
		pressing shift in any mode will start highlighting.
		
		also, because GLASS supports multi-focus, you can type in several fields at once.
		just control click on any field, and it will add itself to the focus list, instead
		of replacing it.  at which point all keyboard events are sent to all fields... this is very 
		usefull to clear several fields or prefix sever things at once.
		
		also note that control double-clicking will highlight words without clearing the focus,
		so you can highlight words in several fields and then clear all by pressing delete!
		
		if you use the scrollwheel on a field without it being focused, you will scroll the text within.
		
		note that if your label is piped to some text which is formatted, your field will automatically
		follow that format.  So your field can become an integer field, if its connected to
		an integer liquid.
	}
	;-  \ documentation
]



slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	marble-lib: slim/open 'marble none
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill
		link*: link 
		unlink*: unlink 
		dirty*: dirty
	]
	
	
	sillica-lib: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		prim-glass
		top-half
		bottom-half
		do-action 
		do-event
		clip-to-marble
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection !piped-to-string]
	event-lib: slim/open 'event none

	


	;--------------------------------------------------------
	;-   
	;- !FIELD[ ]
	!field: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
			;-        cursor-index:
			; this is the index of the cursor within the label
			cursor-index: 2
			
			
			;-        cursor-highlight:
			cursor-highlight: none
			
			
			;-        label-index:
			; what is the first visible character in the field?
			; this is used by the field to make sure that the cursor is always visible,
			; otherwise, it will run off out of view.
			label-index: 1

			
			;-        focused?:
			focused?: false
			
			
			;-        label:
			label: ""
			
			
			;-        color:
			color: black
			
		]

		;-    label-backup:
		; when focus occurs, store our label here
		; if escaped, we go back to it.
		label-backup: none
		

		
		;-    Material[]
		material: make material []
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'field  
			
			
			;-        field-font:
			; font used by the gel, which is MONOSPACE for now.
			field-font: theme-field-font
			
			;-        font-width:
			; used temporarily to calculate index 
			font-width: theme-field-char-width
			
			
			;-        cursor-x:
			cursor-x: 0
			highlight-x: 0
			
			hbox-s: 0x0
			hbox-e: 0x0
			
			clr1: none
			clr2: none
			clr3: none
			
			corner: none
			d: none ; dimension
			p: none ; position
			e: none ; box end (dimension + position)
			f?: none ; focused?
			c: none ; center
			
			highlight-color: 0.0.0.50
			
			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				valve: make valve [
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						label !string ("")
						cursor-index !integer
						cursor-highlight !any ; maybe integer or none
						focused? !bool
						hover? !bool
						label-index !integer
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
						; event backplane
						position dimension 
						[
							line-width 1 
							pen none 
							fill-pen (to-color gel/glob/marble/sid) 
							box (data/position=) (data/position= + data/dimension= - 1x1)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color label hover? focused? cursor-index cursor-highlight label-index
						[
							(
								corner: 1
								d: data/dimension=
								p: data/position=
								e: d + p - 1x1
								c: d / 2 + p - 1x1
								f?: data/focused?=
								vrange: visible-range gel/glob/marble 
								cursor-x: ( data/cursor-index= - data/label-index= + 1 * font-width) * 1x0
								if data/cursor-highlight= [
									highlight-x: ( data/cursor-highlight= + 1 - data/label-index= * font-width) * 1x0
									hbox-s: min (max p + 0x1 (cursor-x + p + -3x0)) e + 0x-1
									hbox-e: min (max p + 0x3 (p + highlight-x + (0x1 * d) - 3x1)) e - 0x1
								]
							 []
							)
							line-width 1
							pen none
							
							; bg
;							fill-pen linear (p) 1 (d/y) 90 1 1 
;								(white * .98) 
;								(white * .98) 
;								(white) 
							fill-pen white
							box (p) (e) 3
							
							
							; top shadow
							fill-pen linear (p) 1 (4) 90 1 1 
								(0.0.0.180) 
								(0.0.0.220) 
								(0.0.0.245) 
								(0.0.0.255 )
							box (p) (e) (corner)

							
							pen none
							(
								either all [data/cursor-highlight= data/focused?=] [
									compose [
										fill-pen 255.255.255.200
										box (hbox-s) (hbox-e) (corner)
									]
								][[]]
							)
							
							
							
							fill-pen none
							
							; basic text
							line-width 1
							(
								prim-label copy/part at data/label= vrange/1 at data/label= (vrange/2 + 1) p + 4x1 d data/color= field-font 'west
							)
							
							(	
								either f?  [
									compose [
										; highlight box
										(
											compose either data/cursor-highlight= [
												prim-glass hbox-s hbox-e theme-color 190
												
											][
												[]
											]
										)
										
										; add cursor
										(
											compose either data/cursor-highlight= [
												[
													pen (red)
													fill-pen none
													line-width 1
													line ( cursor-x + p - 2x0)
														 (p + cursor-x + (0x1 * d) - 2x2)
												]
											][
												[
													pen (red)
													fill-pen none
													line-width 2
													line ( cursor-x + data/position= - 3x0)
														 (data/position= + cursor-x + (0x1 * data/dimension=) - 3x2)
												]
											]
										)
									]
								][
									[]
								]
							)


							


							; draw edge highlight?
							( 
								compose either any [data/hover?= f? ][
									[
										line-width 2
										fill-pen none
										pen (theme-color + 0.0.0.150)
										box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) (corner)
										pen theme-knob-border-color
										fill-pen none
										line-width 1
										box (data/position=) (data/position= + data/dimension= - 1x1) (corner)
									]
								][[
									; simple gray border
									pen theme-knob-border-color
									fill-pen none
									line-width 1
									box (data/position=) (data/position= + data/dimension= - 1x1) (corner)
								]]
							)
							

						]
							
						; controls layer
						;[]
						
						; overlay layer
						; like the bg, it may switched off, so don't depend on it.
						;[]
					]
				]
			]
			
			
			;-----------------
			;-        set-cursor-from-coordinates()
			;-----------------
			set-cursor-from-coordinates: func [
				marble [object!]
				offset [pair!]
				highlight? [logic! none!]
			][
				vin [{set-cursor-from-coordinates()}]
				i: offset/x
				i: to-integer (i + 6 / font-width)
				i: -1 + i + any [content* marble/aspects/label-index 1]
				
				move-cursor marble i highlight?
				vout
			]
			
			




			;-----------------
			;-        cut-highlight()
			;-----------------
			cut-highlight: funcl [
				marble
				/only "does not default to whole string if nothing is highlighted"
			][
				vin [{cut-highlight()}]
				i: content* marble/aspects/cursor-index
				h: content* marble/aspects/cursor-highlight
				t: content* marble/aspects/label
				if h [
					either only [
						s: get-highlight marble/only
					][
						s: get-highlight marble
					]
					
					any [
						all [  h   i < h  (vprint "CUT FROM INDEX" 1) remove/part at t i at t h]
						all [  h  (vprint "CUT FROM INDEX reverse" 1) remove/part at t h at t i]
						all [not only  (vprint "CUT FROM ALL" 1) t]
					]
					
					fill* marble/aspects/cursor-highlight none
					
					move-cursor marble min i h false
				]
				vout
				s
			]
			
			
			
			
			;-----------------
			;-        move-cursor()
			;-----------------
			move-cursor: func [
				marble
				to [integer!]
				highlight? [logic! none!] "none means, leave it as-is"
				/local vrange new-index range
			][
				vin [{set-cursor()}]
				
				; force bounds
				to: normalize-cursor-index marble to
				
				; none means, leave it as-is
				unless none? highlight? [
					either highlight? [
						highlight marble
					][
						unhighlight marble
					]
				]
				; make sure the cursor doesn't move outside of field.
				vrange: visible-range marble
				if (to - 1) > (vrange/2 ) [
					range: vrange/2 - vrange/1
					new-index: to - range - 1
					fill* marble/aspects/label-index new-index
				]
				if to  < vrange/1 [
					fill* marble/aspects/label-index to
				]
				fill* marble/aspects/cursor-index to
				vout
			]
			
			
			;-----------------
			;-        visible-range()
			;-----------------
			visible-range: func [
				marble
				/local from to
			][
				vin [{visible-range()}]
				
				from: max 1 any [content* marble/aspects/label-index 1]
				to: -2 + from + to-integer (first (content* marble/material/dimension) / marble/valve/font-width)
				to: min to length? content* marble/aspects/label
				
				vout
				reduce [from to]
			]
			
			;-----------------
			;-        visible-length?()
			;-----------------
			visible-length?: func [
				marble
				/local vrange
			][
				vin [{visible-length?()}]
				vrange: visible-range marble
				
				
				;v?? vrange
				
				vout
				1 + vrange/2 - vrange/1
			]
			
			
			
			
			;-----------------
			;-        insert-content()
			;-----------------
			insert-content: func [
				marble
				data [string! integer! decimal! tuple! tag! issue! char!]
				/local i t
			][
				vin [{insert-text()}]
				; just in case
				cut-highlight marble
				
				data: switch/default type?/word data [
					string! [data ]
					char! [to-string data]
				][
					mold data
				]
				; fields may not contain other whitespaces than space.
				data: replace/all data "^/" " "
				data: replace/all data "^-" " "
				
				i: content* marble/aspects/cursor-index
				t: content* marble/aspects/label
				
				insert at t i data
				
				move-cursor marble i + length? data false

				fill* marble/aspects/label t
				vout
			]
			
			
			
			
			;-----------------
			;-        highlight()
			;
			; by default, does nothing if field is already highlighted
			;-----------------
			highlight: func [
				marble
				/reset "reset cursor-highlight even if its already set"
			][
				vin [{highlight()}]
				if any [
					not content* marble/aspects/cursor-highlight
					reset
				][
					fill* marble/aspects/cursor-highlight content* marble/aspects/cursor-index
				]				
				vout
			]


			;-----------------
			;-        unhighlight()
			;-----------------
			unhighlight: func [
				marble
			][
				vin [{unhighlight()}]
				; don't propagate unhighlight if its already the case
				if content* marble/aspects/cursor-highlight [
					fill* marble/aspects/cursor-highlight none
				]
				vout
			]

			
			;-----------------
			;-        normalize-cursor-index()
			;-----------------
			normalize-cursor-index: func [
				marble [object!]
				index [integer!]
			][
				min 1 + length? content* marble/aspects/label max 1 index
			]
			
			
			;-----------------
			;-        normalize-label-index()
			;-----------------
			normalize-label-index: func [
				marble [object!]
				index [integer!]
			][
			
				min 1 + ((length? content* marble/aspects/label) - visible-length? marble) max 1 index
			]
			
			
			;-----------------
			;-        set-label-index()
			;-----------------
			set-label-index: func [
				marble
				index [integer!]
			][
				vin [{set-label-index()}]
				index: normalize-label-index marble index
				if index <> any [content* marble/aspects/label-index 1] [
					fill* marble/aspects/label-index index
				]
				vout
			]
			
			
			
			
			;-----------------
			;-        set-highlight()
			;-----------------
			set-highlight: func [
				marble
				from [integer!]  "from is cursor-highlight"
				to [integer!] "to will become cursor"
			][
				vin [{set-highlight()}]
				
				from: normalize-cursor-index marble from
				to: normalize-cursor-index marble to
				
				fill* marble/aspects/cursor-highlight from
				fill* marble/aspects/cursor-index to
				vout
			]
			
			
			;-----------------
			;-        find-word()
			;-----------------
			find-word: func [
				marble
				start [integer!]
				/reverse
				/local aspects i t 
			][
				vin [{find-next-word()}]
				t: content* marble/aspects/label
				
				either reverse [
					i: start
					; skip spaces
					while [#" " = pick t i - 1] [
						i: i - 1
					]
					either t: find/reverse/tail at t i  " " [
						i: index? t
					][
						; if there is no space beyond cursor, go at head
						i: 1
					]			
				][
					either t: find/tail at t start  " " [
						i: index? t
						t: head t 
						; skip spaces
						while [#" " = pick t i] [
							i: i + 1
						]
					][
						; if ther is no space beyond cursor, go at end
						i: 10000000
					]			
				]
				vout
				i
			]
			
			
			;-----------------
			;-        highlight-word()
			;-----------------
			highlight-word: func [
				marble
				/local aspects i h t
			][
				vin [{highlight-word()}]
				
				highlight/reset marble
				
				i: content* marble/aspects/cursor-index
				h: i
				t: content* marble/aspects/label
				
				either #" " = pick t i [
					;-------
					; highlight spaces
					;-------
					either i >= h [
						; select spaces
						while [#" " = pick t i] [
							i: i + 1
						]
						while [#" " = pick t h - 1] [
							h: h - 1
						]
					][
						; select spaces
						while [#" " = pick t h] [
							h: h + 1
						]
						while [#" " = pick t i - 1] [
							i: i - 1
						]
					]
					
					set-highlight marble h i
					
				][
					;-------
					; highlight word
					;-------
					; we keep orientation of highlight!
					either i >= h [
						; select all but spaces
						while [all [pick t i #" " <> pick t i] ] [
							i: i + 1
						]
						while [all [pick t h #" " <> pick t h - 1] ] [
							h: h - 1
						]
					][
						; select all but spaces
						while [all [pick t h #" " <> pick t h]] [
							h: h + 1
						]
						while [all [pick t i #" " <> pick t i - 1] ] [
							i: i - 1
						]
					]
					set-highlight marble i h
				]
				
				
				
				vout
			]
			
			
			
			
			;-----------------
			;-        handle-typing()
			;
			; <TO DO> filter valid character types on event.
			;-----------------
			handle-typing: func [
				event [object!]
				/local aspects i t l k m h
					   fill?
			][
				vin [{handle-typing()}]
					
				aspects: event/marble/aspects
				vprint ["typing into : " content* aspects/label]
				vprobe event/key
				
				
				i: content* aspects/cursor-index
				t: content* aspects/label
				l: length? t
				k: event/key
				m: event/marble
				h: content* aspects/cursor-highlight
				
				fill?: switch/default k [
					; generate an unfocus
					escape [
						; we restore the previous text we had before the focus occured
						fill* aspects/label m/label-backup
						event-lib/queue-event event-lib/clone-event/with event [action: 'unfocus ]
						false
					]
					
					enter [
						; in a field, the enter event, causes a 'set-text and an 'unfocus 
						event-lib/queue-event event-lib/clone-event/with event [
							action: 'set-text
							;text: t  ; if you set this to a string, it will fill the label within handler.
						]
						event-lib/queue-event event-lib/clone-event/with event [action: 'unfocus ]
						false
					]
					
					erase-current [
						either h [
							cut-highlight m
						][
							if i <= l [
								remove at t i
							]
						]
						true
					]
					
					erase-previous [
						either h [
							cut-highlight m
						][
							if i > 1 [
								i: i - 1
								remove at t i
								fill* aspects/cursor-index i
							]
						]
						true
					]
					
					erase-all [
						unhighlight m
						cut-highlight m
						true
					]
					
					select-all [
						set-highlight m 1 100000
						false
					]
					
					move-right [
						move-cursor m i + 1 event/shift?
						false
					]
					
					move-left [
						move-cursor m i - 1 event/shift?
						false
					]
					
					move-to-begining-of-line [
						move-cursor m 1 event/shift?
						false
					]
					
					move-to-next-word move-up [
						i: find-word m i ; can return past tail !
						move-cursor m i event/shift?
						false
						
					]
					
					move-to-previous-word move-down [
						i: find-word/reverse m i ; can return past tail !
						move-cursor m i event/shift?
						false
					]
					
					move-to-end-of-line [
						move-cursor m l + 1 event/shift?
						false
					]
					
					cut [
						if t: cut-highlight m [
							write clipboard:// t
						]
						false
					]
					
					copy [
						write clipboard:// get-highlight event/marble
						fill* aspects/cursor-highlight none
						false
					]
					
					
					paste [
						; read returns none if clipboard doesn't contain plaintext
						if l: read clipboard:// [
							; just make sure we don't try to paste a 700MB file!
							if 1024 < length? l[
								l: copy/part l 1024
							]
							insert-content m l
						]
						true
					]
					
					
				][
					unless word? k [
						insert-content m k
					]
					true
				]
				if fill? [
					fill* aspects/label t
				]


				vout
				
			]
			
			;-----------------
			;-        get-highlight()
			; returns none if nothing is highlighted
			;-----------------
			get-highlight: func [
				marble
				/only "does not default to whole string if nothing is highlighted"
				/local h i t
			][
				i: content* marble/aspects/cursor-index
				h: content* marble/aspects/cursor-highlight
				t: content* marble/aspects/label
				any [
					all [  h   i < h   copy/part at t i at t h]
					all [  h   copy/part at t h at t i]
					all [not only t]
				]
			]
			
						

			
			
			;-----------------
			;-        ** field-handler() **
			;
			; this handler is used for testing purposes only. it is shared amongst all marbles, so its 
			; a good and memory efficient handler.
			;-----------------
			field-handler: func [
				event [object!]
				/local field i txt
			][
				vin [{HANDLE FIELD}]
				vprint event/action
				
				field: event/marble
				action-event: event
				
				switch/default event/action [
					start-hover [
						clip-to-marble event/marble event/viewport
						fill* event/marble/aspects/hover? true
					]
					
					end-hover [
						clip-to-marble event/marble event/viewport
						fill* event/marble/aspects/hover? false
					]
					
					select [
						vprint event/coordinates
						vprint ["tick: " event/tick]
						vprint ["fast-clicks: "event/fast-clicks]
						vprint ["coordinates: " event/coordinates]
						either true = content* event/marble/aspects/focused? [
							set-cursor-from-coordinates event/marble event/offset event/shift?
							
							if event/fast-clicks [
								either event/fast-clicks > 1 [
									; higlight all on triple click
									set-highlight event/marble 1 2000000
								][
								; highlight word or space on double click
									highlight-word event/marble
								]
							]
						][
							event/action: 'focus
							; tell the system that WE want to be focused
							event-lib/queue-event event
						]
					]
					
					scroll [
						vprint "scrolling!"
						vprint content* field/aspects/label-index
						
						i: any [content* field/aspects/label-index 1]
						i: i + either event/direction = 'pull [ 1][-1]
						v?? i
						set-label-index field i
						clip-to-marble event/marble event/viewport
					]
					
					focused-scroll [
						; lets be lazy and requeue it as text-entry event!
						; then any cool side-effects are handled for free (ctrl + shift)
						;
						; note that 'text-entry action bypasses window and core key handlers.
						event-lib/queue-event compose [
							action: 'marble-text-entry
							view-window: (event/view-window)
							coordinates: (event/coordinates)
							marble: (event/marble)
							key: (either event/direction = 'pull [to-lit-word 'right][to-lit-word 'left])
							shift?: (event/shift?)
							control?: (event/control?)
						]
						
					]
					
					swipe drop? [
						set-cursor-from-coordinates event/marble event/offset true
					]
					
					focus [
						event/marble/label-backup: copy content* event/marble/aspects/label
						if pair? event/coordinates [
							set-cursor-from-coordinates event/marble event/offset false
						]
						fill* event/marble/aspects/focused? true
						clip-to-marble event/marble event/viewport
					]
					
					unfocus [
						event/marble/label-backup: none
						fill* event/marble/aspects/focused? false
						clip-to-marble event/marble event/viewport
					]
					
					text-entry marble-text-entry [
						handle-typing event
						dirty* event/marble/aspects/cursor-index
						;clip-to-marble event/marble event/viewport
					]
					
					
					; this should be used to set the text and force its action to evaluate.
					; note that this event doesn't cause any gfx change, beyond changing the text in the field.
					set-text [
						;vprint "%%%%"
						if all [
							in event 'text
							string? event/text 
						][
							fill event/marble/aspects/label event/text
						]
						;--------------
						; convert the event into a vanilla end-user default action.
						event/action: 'action
						
					]

					
				][
					vprint "IGNORED"
					action-event: none
				]
				
				if action-event [
					do-event action-event
				]
				
				vout
				none
			]
			


			;-----------------
			;-        setup-aspects()
			;-----------------
			; make sure the label is always a string, when piped.
			;-----------------
			setup-aspects: func [
				marble
			][
				;---
				; makes the field's label always a string, when piped.
				marble/aspects/label: liquify*/fill !piped-to-string	marble/aspects/label
			]


			;-----------------
			;-        setup-style()
			;-----------------
			; a callback to extend anything in the marble AFTER Glass has finished with its own setup
			;
			; this is used by styles for their own custom data requirements.
			;
			; styles may also provide application setup hooks, but usually do so via extensions to the
			; the specification parser, using dialect()
			; 
			; some styles will also add default stream handlers (like viewports)
			;-----------------
			setup-style: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/stylize()}]
				
				; just a quick stream handler for all marbles
				event-lib/handle-stream/within 'field-handler :field-handler marble
				vout
			]
		]
	]
]
