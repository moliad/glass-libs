REBOL [
	; -- Core Header attributes --
	title: "Glass script editor marble"
	file: %style-script-editor.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {Multi-line Text-entry for GLASS.  Optimised to edit source code.}
	web: http://www.revault.org/modules/style-script-editor.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-script-editor
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-script-editor.r

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
		2013-09-04 - v0.8.1
			-pressing enter (adding new line) now properly indents cursors
	
		v1.0.0 - 2013-09-18
			-License changed to Apache v2
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Its event handling is quite extensive, with a few shortcuts for source editing built-in.
		
		using the control key in any state allows per word movement or selection using
		the arrows OR the scrollwheel.
		
		pressing shift in any mode will start highlighting.
		
		also, because GLASS supports multi-focus, you can type in several editors/fields at once.
		just control click on any editor, and it will add itself to the focus list, instead
		of replacing it.  at which point all keyboard events are sent to all editors... this is very 
		usefull to clear several editors or prefix sever things at once.
		
		also note that control double-clicking will highlight words without clearing the focus,
		so you can highlight words in several editors and then clear all by pressing delete!
		
		if you use the scrollwheel on a editor without it being focused, you will scroll the text within.
		
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
		notify*: content 
		fill*: fill
		link*: link
		unlink*: unlink
		dirty*: dirty
		bridge*: bridge
		attach*: attach
	]
	
	glue-lib: slim/open 'glue none
	
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
		prim-text-area
		do-event
	]
	
	
	slim/open/expose 'utils-series none [ shorter? shorten elongate TEXT-TO-LINES remove-duplicates]
	slim/open/expose 'utils-words none [ swap-values ]

	epoxy-lib: slim/open/expose 'epoxy none [ !box-intersection ]
	event-lib: slim/open 'event none

	


	;--------------------------------------------------------
	;-   
	;- !EDITOR[ ]
	!editor: make marble-lib/!marble [
	
	
		;-    stored-cursors:
		;
		; when we need to store the cursor positions for some reasons, we store them here.
		;
		; this is usually used when navigating the mouse up and down, so as to allow the cursors to go
		; back to their positions before changing lines, if intermediate lines where shorter.
		;
		; its also used by the swiper to remember what selections looked like when mouse was pressed.
		stored-cursors: none
		
	
	
		;-    Aspects[ ]
		aspects: make aspects [
			;        size:
			size: 200x100
			
			;        padding:
			;
			; edges to remove from editing area in pixels,
			; this includes visible edges.
			padding: 3x3
			
			;-        color:
			; bg color
			color: white
			
			;        focused?:
			focused?: false
			
			;        font:
			font: theme-editor-font
			
			
			
			
			;-        cursor-index:
			; this is the index of the cursor within the label
			cursor-index: 1
			
			;-        cursor-highlight:
			cursor-highlight: none
			
			
			;-        top-off:
			; what is the first visible line in the editor line?
			; this is used by the editor to make sure that the cursor is always visible,
			; otherwise, it would run off out of view.
			top-off: 1
			
			
			;-        left-off:
			; what is the first visible column in the editor?
			left-off: 1
			
			
			;-        edit-options:
			; 
			; these are used to control how editing occurs (insert, overwrite, etc)
			edit-options: none
			
			
			;-        text:
			; 
			; this will be set to a special pipe client which merges the paragraphs
			; into a single string
			text: ""
			
			
			
			;-        key-words:
			; a set of words which will be displayed in an alternate color
			key-words: none
			
			
			
			;-        leading:
			; extra space between lines, can be negative.
			leading: 7
			
			
			;-        cursors:
			; a list of text cursors for the editor first character is 1x1
			cursors: [ ]
			
			;-        selections:
			selections: [ ]
			
			
			;-        modes:
			; a block of words which holds optional modes for the editor
			;
			;   indented-new-line
			;   overwrite mode
			modes: none
			
			;--------------------------
			;-        editable?:
			;
			; when true (by default) the editor can be edited.
			;
			; otherwise, the editor acts as a plain scrollable text box.
			;--------------------------
			editable?: true
			
			
			;--------------------------
			;-        search-string:
			;
			; when set, some display and events might react differently.
			;
			; a string of text to use for any search operations.
			;--------------------------
			search-string: none
			
			
		]


		
		;-    Material[]
		material: make material [
			;-        min-dimension:
			min-dimension: 200x100
			
			
			
			
			;-        fill-weight:
			fill-weight: 1x1
			
			;-        history:
			; stores undo/redo information
			; 
			; we store our history in a plug, just for fun.
			; it will be a bulk, which allows us to use bulk diagnostic nodes to
			; display or act on the history.
			history: none
			
			
			;-        lines:
			;
			; the actual content of the editor, is stored as a bulk of size 1
			; 
			; we will initialize this plug as a !text-lines plug which automatically
			; purifies input into the expected bulk when its not the case.
			lines: none
			
			
			;-        number-of-lines:
			; number of lines in lines material.
			number-of-lines: none
			
			
			;-        longest-line:
			;
			; length of longest line
			;
			; this value is filled-out rather lazily... we just keep incrementing it whenever a line is longer than this value.
			;
			; this can be linked to an horizontal scrollbar
			longest-line: none



			;-        view-size:
			; calculated editable area in pixels (dimension - padding - padding)
			view-size: none
			
			
			;-        view-width:
			; part of editor which actually can display characters in pixels (view-size/x)
			view-width: none
			
			
			;-        view-height:
			view-height: none
			
			
			;-        font-width:
			; extracts width from font.
			font-width: none
			
			
			;-        font-height:
			; extracts size from font.
			font-height: none
			
			
			;-        line-height:
			; font-height + leading
			line-height: none
			
			
			;-        visible-length:
			; number of characters that fit within view-width
			; this can be directly linked to scrollbar
			; view-width / font-width
			visible-length: none
			

			;-        visible-lines:
			; view-height / font/size
			visible-lines: none
			
			
			;-        hover-cursor:
			; whenever the mouse hovers over the interface, we update this value with the current
			; position of the mouse.
			;
			; its none when not focused or if the mouse is outside the view.
			hover-cursor: none
			
		
		]
		
		
		;-    valve[ ]
		valve: make valve [
			type: '!marble
		
			;-        style-name:
			style-name: 'script-editor  
			
			
			;-        editor-font:
			; font used by the gel, which is MONOSPACE for now and MUST include the char-width value within.
			;editor-font: theme-editor-font
			
			
			;-        font-width:
			; used temporarily to calculate index 
			;font-width: theme-editor-char-width
			
			
			;-        cursor-x:
			cursor-x: 0
			highlight-x: 0
			
			hbox-s: 0x0
			hbox-e: 0x0
			
			clr1: none
			clr2: none
			clr3: none
			
			d: none ; dimension
			p: none ; position
			e: none ; box end (dimension + position)
			f?: none ; focused?
			c: none ; center
			
			highlight-color: 0.0.0.50
			

			;-        text-characters:
			text-characters: charset [#"a" - #"z"]


			
			;-----------------
			;-        materialize()
			;-----------------
			materialize: func [
				editor
				/local mtrl aspects
			][
				vin [{materialize()}]
				mtrl: editor/material
				aspects: editor/aspects
				
				mtrl/lines: liquify*/with/piped/fill !plug [ valve: make valve [pipe-server-class: epoxy-lib/!bulk-lines] ] ""
				
				attach*/preserve aspects/text mtrl/lines
				; we mutate the text aspect into a text bulk joiner.
				aspects/text/valve: epoxy-lib/!bulk-join-lines/valve
				
				mtrl/longest-line: liquify*/fill !plug 10
				
				mtrl/view-size: liquify*/link epoxy-lib/!pair-subtract reduce [mtrl/dimension aspects/padding aspects/padding]
				mtrl/view-width: liquify*/link epoxy-lib/!x-from-pair mtrl/view-size
				mtrl/view-height: liquify*/link epoxy-lib/!y-from-pair mtrl/view-size
				
				
				mtrl/number-of-lines: liquify*/link glue-lib/!length mtrl/lines
				
				mtrl/font-width: liquify*/link/with glue-lib/!get-in-ctx aspects/font [attribute: 'char-width]
				mtrl/font-height: liquify*/link/with glue-lib/!get-in-ctx aspects/font [attribute: 'size]
				mtrl/line-height: liquify*/link glue-lib/!fast-add [mtrl/font-height aspects/leading]
				
				
				mtrl/visible-length: liquify*/link glue-lib/!divide reduce [mtrl/view-width mtrl/font-width]
				mtrl/visible-lines: liquify*/link glue-lib/!divide reduce [mtrl/view-height mtrl/line-height]
				
				mtrl/hover-cursor: liquify*/fill !plug none
				
				vout
			]
			
			
			
			;-----------------
			;-        get-lines()
			;-----------------
			get-lines: func [
				lines [block!]
				cursors [block! pair!]
				/local cursor line my-lines
			][
				vin [{get-lines()}]
				my-lines: copy []
				if pair? cursors [cursors: insert clear [] cursors]
				
				foreach cursor cursors [
					if line: pick next lines cursor/y [
						line: at line cursor/x
						append my-lines line
					]
				]
				vout
				
				
				my-lines
			]
			
			
			
			
			;-----------------
			;-        insert-char()
			;
			; this is currently very prototypish, but with more stuff implemented, it will get overhauled.
			;-----------------
			insert-char: func [
				key [char!] "the character to insert"
				cursors [block! pair!] ""
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				/local line k control? shift? cursor crs c
			][
				vin [{insert-char()}]
				
				if pair? cursors [cursors: insert clear [] cursors]
				
				until [
					cursor: first cursors
					
					if line: pick lines cursor/y [
						line: at line cursor/x
						insert line key
						cursor: cursor + 1x0
						crs: head cursors
						forall crs [
							c: first crs
							if all [
								c/y = cursor/y 
								c/x >= cursor/x
							][
								change crs (c + 1x0)
							]
						]

						change cursors cursor
					]
					tail? cursors: next cursors
				]
				
				vout
			]
			

			;-----------------
			;-        insert-text()
			;-----------------
			insert-text: func [
				text [string!] "the text to insert"
				cursors [block! pair!] "where to insert text"
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				/local line shift cursor str i line-i
			][
				vin [{insert-char()}]
				
				if pair? cursors [cursors: insert clear [] cursors]
				
				; get a compatible version of the text to our lines setup.
				text: text-to-lines text

				
				until [
					cursor: first cursors
					line: pick lines cursor/y
					text: head text
					
					;change cursors 1x0 + cursor
					
					case [
						(length? text ) >= 3 [
							; first line
							str: copy at line cursor/x
							clear at line cursor/x
							insert tail line first text
							
							i: (length? text) - 2
							shift: 1x1
							line-i: at lines cursor/y
							
							until [
								shift: shift + 0x1
								insert line-i: next line-i first text: next text
								0 = i: i - 1
							]
							
							; last lines
							insert next line-i  rejoin [ last text str ]
							str: second text
							shift: shift + (1x0 * ((length? str ) - cursor/x))
							move-cursors cursor head cursors ((0x1 * length? head text) - 0x1) shift shift
						]
						
						(length? text) = 2 [
							str: copy at line cursor/x
							clear at line cursor/x
							insert tail line first text
							insert next at lines cursor/y rejoin [ second text str ]
							str: second text
							shift: 1x0 * ((length? str ) - cursor/x) + 1x1
							move-cursors cursor head cursors 0x1 shift shift
						]
						
						(length? text) = 1 [
							insert at line cursor/x str: first text
							shift: (1x0 * length? str)
							move-cursors cursor head cursors 0x0 shift shift
						]
					
					]

					tail? cursors: next cursors
				]
				vout
			]

			;-----------------
			;-        delete-text()
			;
			; given two cursor positions, this will remove all text between them
			;-----------------
			delete-text: func [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				from [pair!]
				to [pair!]
				/local top-down? shifts *to
			][
				vin [{delete-text()}]
				v?? from
				v?? to
				top-down?: true
				if any [
					from/y > to/y
					all [
						from/y = to/y 
						from/x > to/x
					]
				][
					swap-values from to
					top-down?: false
				]
				v?? top-down?
				*to: to
				until [
					; calculate box of current line to highlight
					either from/y = to/y [
						; first line
						line: pick lines to/y
						vprint "trimming first line"
						vprint line
						either to/x = -1 [
							clear at line from/x
							append line pick lines to/y + 1
							remove at lines to/y + 1
						][
							remove/part at line from/x at line to/x
						]
					][
						either to/x = -1 [
							;intermediate lines
							line: pick lines to/y
							remove at lines to/y
							vprint "removing line"
							vprint line
						][	
							; last line
							line: pick lines to/y
							remove/part line to/x - 1
							vprint "trimming last line"
							vprint line
						]
					]
					
					to: to - 0x1
					to/x: -1
					from/y > to/y
				]
				
				; calculate offsets.
				shifts: clear []
				v?? from
				v?? *to
				either top-down? [
					vprobe "TOP-DOWN"
					; inputs where swapped (cursor is at end of selection)
					append shifts *to - from * 0x-1
					append shifts *to - from * -1x-1 
					append shifts *to - from * -1x-1 ; - 1x0
					;curso
				][
					vprobe "DOWN-TOP"
					; input was left as-is (cursor is at head of selection)
					append shifts *to - from * 0x-1
					append shifts 0x0
					append shifts 0x0
				]
				
				vout
				shifts
			]
			
			
			;-----------------
			;-        delete-selections()
			;
			; given two cursor positions, this will remove all text between them
			;-----------------
			delete-selections: func [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				cursors [block!]
				selections [block!]
				/local cursor selection deleted?  shifts
			][
				vin [{delete-text()}]
				; selections will always be cleared by normal mouse swiping
				; so we can safely use this as a quick check.
				;
				; this prevents us from having to scan the cursors/selections at each
				; key stroke... much faster.
				unless empty? selections [
					repeat i length? cursors [
						if all [
							cursor: pick cursors i
							selection: pick selections i
							cursor <> selection ; we ignore cursors without selection
						][
							shifts: delete-text lines selection cursor
							deleted?: true
							move-cursors cursor cursors shifts/1 shifts/2 shifts/3
						]
					]
					clear selections
				]
				vout
				deleted?
			]
			
			
			;-----------------
			;-        clean-selections()
			;
			; this function cleans the selections if none of the pairs actually constitute
			; a range when compared to cursors.
			;
			;-----------------
			clean-selections: func [
				"Will clean the selection based on cursors, if selections are useless"
				cursors [block!]
				selections [block!]
				/local cursor selection
			][
				vin [{clean-selections()}]
				v?? cursors
				v?? selections
				unless empty? selections [
					cursors: at cursors length? selections
					selections: back tail selections
					until [
						if all [
							cursor: pick cursors 1
							selection: pick selections 1
						][
							either selection <> cursor [
								; at this point, we have a selection, the previous ones will now be valid.
								break
							][
								; they are the same, so no selection should occur
								remove selections
							]
						]
						cursors: back cursors
						selections: back selections
						empty? head selections
					]
				]
				vout
			]
			
			;-----------------
			;-        fill-selections()
			;
			; does the opposite of clean-selections by filling up the selections with
			; missing cursors.
			;-----------------
			fill-selections: func [
				cursors [block!]
				selections [block!]
			][
				vin [{fill-selections()}]
				vout
				if shorter? selections cursors [
					elongate selections cursors
				]
			]
			
			
			;-----------------
			;-        select-word()
			;-----------------
			select-word: func [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				cursors [block!]
				selections [block!]
				cursor [pair!]
				/local line char selection
			][
				vin [{select-word()}]
				if all[
					line: pick lines cursor/y 
					char: pick line cursor/x 
				][
					either find **whitespace char [
						; select spacing
						;until [
						;]
					][
						; select word
						line: at line cursor/x
						
						; find head of word 
						until [
							line: back line
							any [
								all[
									find **whitespace pick line 1 
									line: next line
								]
								head? line
							]
						]
						selection: 1x0 * (index? line) + (0x1 * cursor)
						; find tail of word 
						line: at head line cursor/x
						until [
							line: next line
							any [
								tail? line
								find **whitespace pick line 1
							]
						]
						cursor: 1x0 * (index? line) + (0x1 * cursor)
						
						elongate cursors selections
						
						change back tail selections selection
						change back tail cursors cursor
					]
				]
				
				vout
			]
			
			
			
			
			;-----------------
			;-        select-line()
			;-----------------
			select-line: func [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				cursors [block!]
				selections [block!]
				cursor [pair!]
				/local line char selection
			][
				vin [{select-line()}]
				if line: pick lines cursor/y [
					elongate cursors selections
					
					change back tail selections (0x1 * cursor) + 1x0
					change back tail cursors 1x0 * (length? line) + (0x1 * cursor) + 1x0
				]
			
				vout
			]
			
			
			
			
			
			;-----------------
			;-        get-selection()
			;-----------------
			get-selection: func [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				cursors [block!]
				selections [block!]
				/with-newlines
				/local selection cursor line text
			][
				vin [{get-selection()}]
				text: clear ""
				
				
				until [
					if selection: pick selections 1 [
						if all [
							cursor: pick cursors index? selections
							cursor <> selection 
						][
							; normalize direction of cursor/selection
							if any [
								cursor/y < selection/y
								all [cursor/y = selection/y cursor/x < selection/x]
							][
								swap-values cursor selection
							]
							
							until [	
								if line: pick lines selection/y [
									either cursor/y = selection/y [
										; last line or single line
										append text copy/part at line selection/x at line cursor/x
									][
										; other lines
										append text copy/part at line selection/x tail line
										append text newline
									]
								]
								selection: selection + 0x1
								selection/x: 1
								selection/y > cursor/y
							]
						]
						if with-newlines [
							append text newline
						]
					]
					tail? selections: next selections
				]
				if all [
					not empty? text 
					with-newlines 
				][
					remove back tail text
				]
				
				
				
				vout
				copy text
			]
			
			
			;--------------------------
			;-        get-selected-lines()
			;--------------------------
			; purpose:  any line which is part of a selection is returned, even if its not fully selected
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    if a line is within two selections, it should not be included twice.
			;           lines are returned in source order, not selection order.
			;
			; tests:    
			;--------------------------
			get-selected-lines: funcl [
				lines [block!] "lines all setup, ready for insertion (any bulk header is skipped)"
				cursors [block!]
				selections [block!]
				/indices "returns the index of each line, instead of the line strings."
			][
				vin "get-selected-lines()"
				outlines: copy []

				unless empty? cursors [
					acc: copy []
					until [
						cursor: pick cursors 1
						selection: pick selections 1
						
						start: cursor/y
						end: any [
							all [selection selection/y]
							start
						]
						
						if start > end [
							swap: start
							start: end
							end: swap
						]
						
						repeat i end - start + 1 [
							append acc i + start - 1
						]
						
						; there may be more cursors than selections.
						selections: next selections
						cursors: next cursors
						tail? cursors
					]
					
					acc: unique acc
					
					either indices [
						outlines: acc
					][
						sort acc
						foreach line acc [
							append outlines pick lines line
						]
					]
					
				]
				lines: cursors: acc: selections: none
				vout
				outlines
			]
			
			

			
			;-----------------
			;-        font-box()
			;-----------------
			font-box: func [
				marble [object!]
				/local box font
			][
				vin [{font-box()}]
				font: content* marble/aspects/font
				box: (font/size + (content* marble/aspects/leading) * 0x1) + (font/char-width * 1x0)
				vout
				box
			]
			
			
			
			;-----------------
			;-        move-cursors()
			;-----------------
			move-cursors: func [
				"pushes all cursors following cursor movement"
				cursor [pair!]
				cursors [block!]
				below-amount [pair!]
				same-line-amount [pair!]
				same-amount [pair!]
				/local c s
			][
				vin [{move-cursors()}]
				
				
				; update other cursors
				until [
					c: first cursors
					case [
						; lines below cursor
						c/y > cursor/y [
							change cursors c + below-amount
							if s: pick selections 1 [
								change selections s + below-amount
							]
						]
						
						; same cursor
						c = cursor [
							change cursors c + same-amount
							if s: pick selections 1 [
								change selections s + same-amount
							]
						]
						
						; same line as cursor, but later on the line
						all [
							c/x > cursor/x
							c/y = cursor/y
						][
							change cursors c + same-line-amount
							if s: pick selections 1 [
								change selections s + same-line-amount
							]
						]
						
						true [0x0]
					]
					selections: next selections
					tail? cursors: next cursors
				]
				cursors: head cursors
				
				vout
			]
			
			
			
			
			;-----------------
			;-        handle-key()
			;
			; this is meant to handle any key based editing of the editor.
			;
			; at this point, we know its not a control key or a shortcut key the application.
			; invalid keys simply do nothing.
			;-----------------
			handle-key: func [
				marble [object!]
				event [object!]
				/local dirty? lines cursors cursor offset new crs c line amount keep-stored-cursors? text spaces
			][ 
				vin [{handle-key()}]
				
				lines: next content* marble/material/lines
				cursors: content* marble/aspects/cursors
				selections: content* marble/aspects/selections
				

				if empty? cursors [
					insert cursors 1x1
				]

				;vprobe event/key

				switch/default event/key [
					;----------------
					;-            -enter
					;----------------
					enter [
						delete-selections lines cursors selections
						until [
							cursor: first cursors
							if line: pick lines cursor/y [
								line: at line cursor/x
								new: copy line
								clear line
								spaces: 0
								parse/all head line [
									any [[ " " | "^/"] (spaces: spaces + 1)]
								]
								insert new copy/part head line spaces
								insert at lines (cursor/y + 1) new
								
;								"pushes all cursors following cursor movement"
;								cursor [pair!]
;								cursors [block!]
;								below-amount [pair!]
;								same-line-amount [pair!]
;								same-amount [pair!]
;								v?? spaces
								amount: -1x0 * (cursor - spaces) + 1x1
;								v?? amount
								move-cursors cursor head cursors  0x1 amount  amount  ;amount: (0x1 + (-1x0 * length? head line) ) amount 
								
								dirty?: true
							]
							tail? cursors: next cursors
						]
						remove-duplicates head cursors
					]
					
					
					;----------------
					;-            -erase-current
					;
					; delete key (on windows)
					;----------------
					erase-current [
;						v?? cursors 
;						v?? selections
						either delete-selections lines cursors selections [
							dirty?: true
						][
							until [
								cursor: first cursors
								if line: pick lines cursor/y [
									line: at line cursor/x
									
									; are we at the end of the line?
									either empty? line [
										; join this line with next one
										if new: pick lines cursor/y + 1 [
;											v?? new
											append line new
											remove at lines cursor/y + 1
											move-cursors cursor head cursors  0x-1 0x0 0x0
										]
									][
										; delete one char from the line.
										remove line
										move-cursors cursor head cursors  0x0 -1x0 0x0 
	
									]
									dirty?: true
								]
								tail? cursors: next cursors
							]
						]
						remove-duplicates head cursors	
					]

					;----------------
					;-            -erase-previous
					;
					; backspace key (on windows)
					;----------------
					erase-previous [
						either delete-selections lines cursors selections [
							dirty?: true
						][
							until [
								cursor: first cursors
								if cursor = 1x1 [break]
								if line: pick lines cursor/y [
									line: at line cursor/x
									
									; are we at the begining of the line?
									either cursor/x = 1 [
										; join this line with previous one
										if all [
											cursor/y > 1
											new: pick lines cursor/y - 1 
										][
;											v?? new
											
											amount: ( 1x0 * length? new) + 0x-1
											
;											v?? amount
											
											append new line
											remove at lines cursor/y
											move-cursors cursor head cursors  0x-1 amount amount
										]
									][
										; delete one char from the line.
										remove back line
										move-cursors cursor head cursors  0x0 -1x0 -1x0 
	
									]
									unless dirty? [dirty?: true]
								]
								tail? cursors: next cursors
							]
							remove-duplicates head cursors	
						]
					]
					
					;----------------
					;-            -escape
					;----------------
					escape [
						; this will unfocus one cursor at a time, until there is only one cursor
						;
						; removes newer cursors by default,
						; pressing shift removes older cursors
						;
						; we cannot map ctrl + escape since this is used natively by Windows!
						if 1 < length? cursors [
							either event/shift? [
								remove cursors
							][
								clear back tail cursors
								if shorter? cursors selections [
									shorten selections cursors
								]
							]
							dirty?: true
						]
					]
					
					
					;----------------
					;-            -select-all
					;----------------
					select-all [
						append clear selections 1x1 
						append clear cursors to-pair reduce [ 1 + length? last lines   length? lines ]
						dirty?: true
					]
					
					
					;----------------
					;-            -move-up / move-down
					;
					; up down arrow keys
					;----------------
					move-up move-down [
						either event/shift? [
							fill-selections cursors selections
						][
							clear selections
						]
						offset: either event/key = 'move-up [0x-1][0x1]
							
						until  [
							cursor: first cursors
							either marble/stored-cursors [
								cursor/x: first pick marble/stored-cursors index? cursors
							][
								marble/stored-cursors: copy cursors
							]
							unless any [
								all [
									event/key = 'move-up
									cursor/y < 2
								]
								all [
									event/key = 'move-down
									cursor/y >= length? lines
								]
							] [
								cursor: add offset cursor
								cursor/x: min cursor/x 1 + length? pick lines cursor/y
								change cursors cursor
								
								unless dirty? [dirty?: true]
							]
							tail? cursors: next cursors
						]
						keep-stored-cursors?: true
					]
					
					
					;----------------
					;-            -move-left
					;
					; left arrow key
					;----------------
					move-left [
						either event/shift? [
							fill-selections cursors selections
						][
							clear selections
						]
						until  [
							cursor: first cursors
							line: pick lines cursor/y
							
							either any [
								cursor/x <= 1
								empty? line
							][
								unless cursor/y <= 1 [
									; we need to wrap to previous line
									cursor/y: cursor/y - 1
									line: pick lines cursor/y
									change cursors (cursor  + (1x0 * length? line))
									unless dirty? [dirty?: true]
								]
							][
								change cursors -1x0 + cursor
								unless dirty? [dirty?: true]
							]
							tail? cursors: next cursors
						]
					]


					;----------------
					;-            -move-right
					;
					; right arrow key
					;----------------
					move-right [
						either event/shift? [
							fill-selections cursors selections
						][
							clear selections
						]
						until [
							cursor: first cursors
							line: pick lines cursor/y
							
							either cursor/x > length? line [
								unless cursor/y >= length? lines [
									; we need to wrap to previous line
									cursor/y: cursor/y + 1
									line: pick lines cursor/y
									change cursors (cursor * 0x1 + 1x0)
									unless dirty? [dirty?: true]
								]
							][
								change cursors 1x0 + cursor
								unless dirty? [dirty?: true]
							]
							tail? cursors: next cursors
						]
					]
					
					

					;----------------
					;-            -move-to-begining-of-line
					;
					; home key
					;----------------
					move-to-begining-of-line [
						either event/shift? [
							fill-selections cursors selections
						][
							clear selections
						]
						until [
							cursor: first cursors
							line: pick lines cursor/y
							
							change cursors (cursor * 0x1) + 1x0
							
							tail? cursors: next cursors
						]
						dirty?: true
					]
					
					
					
					;----------------
					;-            -move-to-end-of-line
					;
					; end key
					;----------------
					move-to-end-of-line [
						either event/shift? [
							fill-selections cursors selections
						][
							clear selections
						]
						until [
							cursor: first cursors
							line: pick lines cursor/y
							
							change cursors (cursor * 0x1) + (1x0 * length? line) + 1x0
							
							tail? cursors: next cursors
						]
						dirty?: true
					]
					
					
					
					;----------------
					;-            -paste
					;
					; (Ctrl+V on windows)
					;----------------
					paste [
						delete-selections lines cursors selections
						if text: read clipboard:// [
							insert-text text cursors lines
							unless dirty? [dirty?: true]
						]
					]
					
					
					;----------------
					;-            -copy
					;
					; (Ctrl+C on windows)
					;----------------
					copy [
						unless empty? selections [
							either event/shift? [
								write clipboard:// get-selection/with-newlines lines cursors selections
							][
								write clipboard:// get-selection lines cursors selections
							]
							dirty?: true
						]
					]
					
					
					;----------------
					;-            -cut
					;
					; (Ctrl+X on windows)
					;----------------
					cut [
						unless empty? selections [
							either event/shift? [
								write clipboard:// get-selection/with-newlines lines cursors selections
							][
								write clipboard:// get-selection lines cursors selections
							]
							delete-selections lines cursors selections
							dirty?: true
						]
					]
					
					
					;--------------------------
					;-            -tab
					;
					; tab doesn't unfocus in the editor, it inserts spaces.
					;
					; tabs are currently hard coded to 4 spaces.
					;
					; <TO DO> proper tabbing... for now it just inserts 4 spaces (but doesn't delete selections!).
					;--------------------------
					tab [
					
						SLINES: get-selected-lines lines cursors selections						
;						
;						v?? SLINES
;						
;						cursors: copy cursors
;						forall cursors [
;							change cursors 0x1 * first cursors
;						]
;						insert-text "    " cursors lines
							; given the lines to change, we just insert or remove a tab
						either event/shift? [
							foreach line slines [
								case [
									(pick line 1) = #"^-" [
										remove line
									]
									
									(pick line 1) = #" " [
										loop 4 [
											either #" " = pick line 1 [
												remove line
											][
												break
											]
										]
									]
								]
							]
							dirty?: true
							forall cursors [
								change cursors  max 1x1 (-4x0 + first cursors)
							]
							
						][
							foreach line slines [
								insert line "    "
							]
							dirty?: true
							forall cursors [
								change cursors  4x0 + first cursors
							]
						]
					]
				][
					;----------------
					;-            -type a character
					;----------------
					if all [
						char? event/key
						not event/control?
					][
						delete-selections lines cursors selections
						insert-char event/key cursors lines
						update-longest-line marble lines
						dirty?: true
					]
				]
				
				if dirty? [
					dirty* marble/material/lines
					dirty* marble/aspects/cursors
				]
				
				unless keep-stored-cursors? [
					marble/stored-cursors: none
				]
					
				
				vout
			]
			
			
			;-----------------
			;-        update-longest-line()
			;-----------------
			update-longest-line: func [
				"Using current cursors and optional lines, adjust longest-line, so it shows all content"
				marble [object!]
				lines [block!]
				/local item line in-len
			][
				vin [{update-longest-line()}]
				
				in-len: len: content* marble/material/longest-line
				
				; update based on cursors
				foreach line lines [
					len: max len (10 + length? line)
				]
				if in-len <> len [
					fill* marble/material/longest-line len
				]
				
				vout
				len
			]
			
			
			
			;-----------------
			;-        cursor-from-offset()
			;-----------------
			; cursors are pairs which indicate where the next text operation should occur.
			;
			; the advantage of using positional indices rather than string pointers, is that
			; the text buffer can change without issue (so we can copy the string with no ill-effect)
			;
			;-----------------
			cursor-from-offset: func [
				marble [object!]
				offset [pair!]
				/local box lines line cursor
			][
				vin [{cursor-from-offset()}]
				padding: content* marble/aspects/padding
				box: font-box marble
				
				; we select the character based on if we click to the left or right of a character
				; this way, if we click nearer to the edge of char, that edge is selected instead of the one
				; we are actually over.
				;
				; this is because we actually select the region "between" chars as opposed to chars themselves.
				offset/x: offset/x + (box/x / 2 )
				
				cursor: (offset - padding / box + 1x0 ) + (0x1 * content* marble/aspects/top-off) + (1x0 * content* marble/aspects/left-off ) - 1x0
				lines: next content* marble/material/lines
				
				
				if cursor/y < 1 [
					cursor/y: 1
				]
				
				if cursor/y > length? lines [
					cursor/y: length? lines
				]
				
				line: pick lines cursor/y
				cursor/x: min cursor/x (1 + length? line )

				vout
				cursor
			]
						
			

			;-----------------
			;-   ** editor-handler() **
			;
			;-----------------
			editor-handler: funcl [
				event [object!]
				;/local editor i mtrl aspects cursor cursors
			][
				vin [{HANDLE EDITOR}]
;				vprint event/action
				
				editor: event/marble
				mtrl: editor/material
				aspects: editor/aspects
				
				if edit?: not not content* aspects/editable? [
					
					switch/default event/action [
						start-hover [
							fill* aspects/hover? true
						]
						
						end-hover [
							fill* aspects/hover? false
						]
						
						hover [
							fill* mtrl/hover-cursor cursor-from-offset editor event/offset
							false
						]
						
						;-             -select
						select [
;							vprint event/coordinates
;							vprint ["tick: " event/tick]
;							vprint ["fast-clicks: "event/fast-clicks]
;							vprint ["coordinates: " event/coordinates]
							unless content* event/marble/aspects/focused? [
								; tell the system that WE want to be focused
								event/action: 'focus
								event-lib/queue-event event
							]
							
							cursor: cursor-from-offset editor event/offset
							cursors: content* editor/aspects/cursors
							selections: content* editor/aspects/selections
							lines: next content* editor/material/lines
							
							
							
							
							
							either event/fast-clicks [
								;probe event/fast-clicks
								switch event/fast-clicks [
									1 [
										select-word lines cursors selections cursor
									]
									
									2 [
										select-line lines cursors selections cursor
									]
									
									3 [
										;select-paragraph lines cursor
									]
								]
							][
	
								either event/control? [
									append cursors cursor
								][
									clear cursors 
									append cursors cursor
									clear selections
									dirty* editor/aspects/selections
								]
							]
							dirty* editor/aspects/cursors
							
							; we store the cursors, so swipe can detect if a new selection is occuring while dragging the mouse.
							editor/stored-cursors: copy cursors
							
						]
						
						;-             -scrollwheel
						scroll focused-scroll [
							;print ">>>>>>>>>>>>>>>>>>"
							s: now/precise
							switch event/direction [
								push [
									fill* aspects/top-off max 1 ((content* aspects/top-off) - event/amount)
								]
								pull [
									fill* aspects/top-off max 1 ((content* aspects/top-off) + event/amount)
								]
							]
							;print difference now/precise s
							;print "<<<<<<<<<<<<<<<<"
						]
						
											
						;-             -swipe
						swipe drop? [
							;set-cursor-from-coordinates event/marble event/offset true
;							vprint 'swiping
							cursors: content* editor/aspects/cursors
							
							; in some cases there may not be any cursors... ignore swipe or drops
							unless empty? cursors [
								cursor: cursor-from-offset editor event/offset
								selections: content* editor/aspects/selections
								
								; first make sure we have as many selections as cursors
								if fill-selections cursors selections [dirty* editor/aspects/selections]
								
								
								; remove selections if they don't constitute an actual selection.
								; this is to make sure that we can do:
								;
								;  if empty? selections []
								;
								; in order to trigger selection code without it slowing down non selection
								; code within keystrokes.
								;
								; because the swipping does little else, it will not slow this down.
								if all [
									not empty? editor/stored-cursors
									cursor <> last editor/stored-cursors
								] [
									change back tail selections last editor/stored-cursors
								]
								change back tail cursors cursor-from-offset editor event/offset
								clean-selections cursors selections
								
								;v?? selections
								;v?? cursors
								
								dirty* editor/aspects/cursors
								fill* editor/material/hover-cursor cursor
							]
						]
						
						
						focus [
							if pair? event/coordinates [
							;	set-cursor-from-coordinates event/marble event/offset false
							]
							fill* aspects/focused? true
						]
						
						
						unfocus [
							fill* aspects/focused? false
						]
						
						
						;-             -text-entry
						text-entry marble-text-entry [
							handle-key editor event
						]
						
						
						;-             -find-string
						find-string [
							if string? text: event/search-string [
								if any [
									not blk: content*  editor/aspects/cursors
									empty? blk
								][
									fill editor/aspects/cursors blk: append any [blk copy []] 1x1
								]
								
								lines: next content* editor/material/lines ;  'NEXT is required to skip bulk header.
								selections: content* editor/aspects/selections 
								
								clear selections
								
								new-cursors: copy []
								foreach cursor blk [
								
									found!: false
									lines: at next head lines cursor/y
									until [
										if line: pick lines 1 [
											if found!: find at line cursor/x text [
												cursor: 0x1 * (-1 + index? lines) + ( 1x0 * (add length? text  index? found!))
												append new-cursors cursor
											]
										]
										cursor/x: 1 ; once we've searched from cursor, search from begining of line
										any [
											tail? lines: next lines
											found!
										]
									]
									; no point in searching again... we're already at end.
									if tail? lines [
										break
									]
								]
								
								append clear blk new-cursors
								foreach cursor blk [
									append selections cursor - (1x0 * length? text)
								]
								dirty editor/aspects/cursors
								dirty editor/aspects/selections
							]
						]
						
						
						
					][
						vprint "IGNORED"
					]
					
					;probe type? event
					
					do-event event
					
				]
				
				vout
				none
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
				event-lib/handle-stream/within 'editor-handler :editor-handler marble
				vout
			]
			
			
			

		
			;-----------------
			;-        dialect()
			;
			; this uses the exact same interface as specify but is meant for custom marbles to 
			; change the default dialect.
			;
			; note that the default dialect is still executed, so you may want to "undo" what
			; it has done previously.
			;
			;-----------------
			dialect: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
			][
				vin [{dialect()}]
				data: none
				
				parse spec [
					any [
						set data string! (
							fill* marble/aspects/text data
						)
						
						| set data block! (
							on-event marble 'text-entry data
						)
						
						| skip
					]
				]

				vout
			]			


			
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
						text !string ("")
						focused? !bool
						hover? !bool
						left-off !integer
						top-off !integer
						lines !block
						leading !integer
						cursors !block
						view-size !pair
						padding !pair
						selections !block
						font !any
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
						position dimension color lines hover? focused? left-off top-off leading cursors view-size padding selections font
						[
							(
								;print "!!!"
								d: data/dimension=
								p: data/position=
								e: d + p - 1x1
								c: d / 2 + p - 1x1
								f?: data/focused?=
							 []
							)
							line-width 1
							pen none
							
							; bg
							fill-pen (data/color=)
							box (p) (e) 3
							

							; top shadow
							fill-pen linear (p ) 1 (5) 90 1 1 
								(0.0.0.180) 
								(0.0.0.220) 
								(0.0.0.245) 
								(0.0.0.255 )
							box (p) (e) 3

							pen none
							fill-pen none
							
							; basic text
							line-width 1
							pen (data/color=)
							(
								either f?  [ 
									 ;-                  PRIM TEXT CALL
									prim-text-area/cursor-lines (p + data/padding=) data/view-size= data/lines= data/font= data/leading= data/left-off= data/top-off= data/cursors= data/selections= red black  (theme-color + 0.0.0.200) yello
								][
									prim-text-area (p + data/padding=) data/view-size= (data/lines=) data/font= (data/leading=) data/left-off= data/top-off= data/cursors= data/selections= black black theme-color + 0.0.0.200
								]
							)
							
														
;							(	
;								either f?  [ 
;									compose [
;										
;										
;											; highlight box
;										(
;										 	compose either data/cursor-highlight= [
;										 		prim-glass hbox-s hbox-e theme-color 190
;										 		
;												[
;													line-width 1
;													
;													
;													fill-pen linear (p) 1 (d/y) 90 1 1 ( highlight-color * 0.6 + 128.128.128.150) ( highlight-color + 0.0.0.150) (highlight-color * 0.5 + 0.0.0.150)
;													pen (black + 0.0.0.150)
;													box  ( hbox-s ) (hbox-e )
;													
;													
;													; shine
;													pen none
;													fill-pen (255.255.255.175)
;													box ( top-half  ( hbox-s + 0x2) (hbox-e - hbox-s ) )
;													
;													; shadow
;													fill-pen linear (p + 0x15) 1 10 90 1 1 
;														0.0.0.255
;														0.0.0.200
;														0.0.0.150
;													box ( hbox-s + 0x15) (hbox-e )
;												]
;											][
;												[]
;											]
;										)
;										
;										; add cursor
;										(
;										 	compose either data/cursor-highlight= [
;										 		[
;													pen (red)
;													fill-pen none
;													line-width 1
;													line ( cursor-x + p - 2x0)
;													     (p + cursor-x + (0x1 * d) - 2x2)
;												]
;											][
;												[
;													pen (red)
;													fill-pen none
;													line-width 2
;													line ( cursor-x + data/position= - 3x0)
;													     (data/position= + cursor-x + (0x1 * data/dimension=) - 3x2)
;												]
;											]
;										)
;									]
;								][
;									[]
;								]
;							)


							; draw edge highlight?
							( 
								compose either any [data/hover?= f? ][
									[
										line-width 2
										fill-pen none
										pen (theme-color + 0.0.0.175)
										box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) 3
										pen white
										fill-pen none
										line-width 1
										box (data/position=) (data/position= + data/dimension= - 1x1) 3
									]
								][[
									; simple gray border
									pen theme-border-color
									fill-pen none
									line-width 1
									box (data/position=) (data/position= + data/dimension= - 1x1) 3
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
		]
	]
]
