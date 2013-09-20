REBOL [
	; -- Core Header attributes --
	title: "Glass scrolled editor"
	file: %group-scrolled-editor.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {a group setup as a source code editor all setup with scrollers.}
	web: http://www.revault.org/modules/group-scrolled-editor.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'group-scrolled-editor
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/group-scrolled-editor.r

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
		v1.0.0 - 2013-09-18
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		Combines a simple list with vertical and horizontal scrollers.
		
		If you provide some options in the specification,  a label a filter field may appear.
		
		The main aspects of all inner marbles are stored in the aspects (refered to, not linked).
		the main advantage is that the list and scroller themselves are pre-linked for you.
		
		So all you have to do is put items in the list, and the scoller will adjust.
		
		Put in some text in the filter, and everything updates.
	}
	;-  \ documentation
]






slim/register [
	
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob]
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		liquify*: liquify 
		content*: content 
		fill*: fill
		pipe*: pipe
		link*: link 
		unlink*: unlink 
		detach*: detach 
		attach*: attach
	]
	sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		on-event
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	group-lib: slim/open 'group none
	
	slim/open/expose 'bulk none [
		make-bulk
	]
	

	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- !SCROLLED-LIST[ ]
	;
	;-----------------------------------------------------------------------------------------------------------
	!group-scrolled-editor: make group-lib/!group [
	
		;---------------------
		;-    aspects[ ]
		;
		; groups implements their own interface, and xfer to their internals, if required.
		;
		; note that some aspects are directly shared with their internals... 
		;      i.e. we just put a second reference to the internal plug here.
		;---------------------
		aspects: make aspects [
			;--------------------------
			;-             text:
			;
			; the text to put or extract from the editor, this is BRIDGED to the internal line version.
			;--------------------------
			text: none
			
			
			;--------------------------
			;-             line-offset:
			;
			; the index of the first visible line
			;--------------------------
			line-offset: none
			
			
			;--------------------------
			;-             column-offset:
			;
			; index of first visible character.
			;--------------------------
			column-offset: none
			
		]
		
		
		;-    material[ ]
		material: make material [
			border-size: 0x0

			
		]


		;--------------------------
		;-    editor-marble:
		;
		; store a reference to the editor itself within the group, for easy reference after
		;--------------------------
		editor-marble: none
		

		;--------------------------
		;-    vscroller-marble:
		;
		; store a reference to the vscroller itself within the group, for easy reference after
		;--------------------------
		vscroller-marble: none
		

		;--------------------------
		;-    hscroller-marble:
		;
		; store a reference to the hscroller itself within the group, for easy reference after
		;--------------------------
		hscroller-marble: none
		

		
		;--------------------------
		;-    content-specification:
		; this stores the spec block we execute on setup.
		;
		; note that because it's declared here (within the marble) all words are bound to the 
		; marble automatically, so assignments work.
		;
		; it is handled normally by a row frame.
		;
		; note that the dialect for the group itself, is completely redefined for each group.
		;
		; remember that the group itself is a frame, so you can set its looks, and layout mode normally.
		;--------------------------
		content-specification: [
			column tight [
				editor-marble: script-editor
				hscroller-marble: scroller
			]
			column tight [
				row tight [
					vscroller-marble: scroller
				]
				pad 20x20
			]
		]
		
		
		;--------------------------
		;-    spacing-on-collect:
		;
		; we don't want any space between group elements
		;--------------------------
		spacing-on-collect: 0x0
		
		
		;--------------------------
		;-    layout-method:
		; group is a frame... make it a column or a row
		;--------------------------
		layout-method: 'ROW
		
		
		;------------------------------------------------------------------------------
		;-    valve []
		;------------------------------------------------------------------------------
		valve: make valve [

			;--------------------------
			;-        style-name:
			;
			; this is the name used by default in stylesheets. (collect-cstyle())
			;--------------------------
			style-name: 'scrolled-editor
		

			;--------------------------
			;-        bg-glob-class:
			;-        fg-glob-class:
			;
			; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
			; 
			; you can add globs to show up in front or behind the grouped content.
			;
			; for a reference on how to use the
			;--------------------------
			bg-glob-class: none
			fg-glob-class: none
			
			
			;-----------------
			;-        setup-style()
			;
			; build up the style on the fly (creating default values, for example).
			;-----------------
			setup-style: func [
				group
			][
				vin [{!scrolled-list/setup-style()}]
				vout
			]
			
			
			;-----------------
			;-        group-specify()
			;
			; low-level group dialect
			;
			; to increase the 
			;-----------------
			group-specify: func [
				group [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				/local data block-count blk
			][
				vin [{!scrolled-list/group-specify()}]
				block-count: 0
				
				vprobe spec
				vprint "-----------"
				parse spec [
					any [
						;here: set data skip (probe data ) :here
						
						set data string! (
							vprint "text !!!"
							v?? data
							;ask "!"
							fill* group/aspects/text data
						)
					
						| set data tuple! (
							vprint "text COLOR!" 
							set-aspect editor-marble 'color data
						)
						

						
						| [ 'with copy data block!] (
							vprint "SPECIFIED A WITH BLOCK"
							do bind/copy data group 
						)
						
						; keyboard events
						| set data block! (
							vprint "Setting up keyboard action handling"
							on-event group/editor-marble 'text-entry data
							vprobe group/editor-marble/actions
						)
						
;						| 'stiff (
;							group/stiffness: 'xy
;							;fill* group/material/fill-weight 0x0
;
;						)
;						| 'stiff-x (
;							group/stiffness: 'x
;							;fill* group/material/fill-weight 0x0
;
;						)
;						| 'stiff-y (
;							group/stiffness: 'y
;							;fill* group/material/fill-weight 0x0
;
;						)
						
;						; remove the label from this group, we don't need it
;						| 'no-label (
;							;probe "Will remove label"
;							;probe type? group/label-marble
;							group/valve/gl-discard group group/label-marble
;							;group/valve/gl-fasten group
;							
;							;halt
;						)
						
;						; set list data or pick action
;						| set data block! (
;							;print "!!!!"
;							;probe first group/list-marble/valve
;							;print "----"
;							;fill* group/aspects/items make-bulk/records/properties 3 data [ label-column: 1]
;							;group/list-marble/valve/specify group/list-marble reduce [data] stylesheet
;							
;							
;							block-count: block-count + 1
;							switch block-count [
;								1 [
;									; lists support 3 columns, one being label, another options and the last being data.
;									; options will change how the item is displayed (bold, strikethru, color, etc).
;									fill* group/aspects/items make-bulk/records/properties 3 data [ label-column: 1]
;								]
;								2 [
;									if object? get in group 'actions [
;										group/list-marble/actions: make group/list-marble/actions [
;											list-picked: make function! [event] bind/copy data group
;										]
;									]
;								]
;							]
;							
;						)
						
						| set data pair! (
							; set the cursor
							
							vprint "PAIRS!!!"
							v?? data
							;fill* group/material/user-min-dimension data
						) 
						
						| skip 
					]
				]
				vprint "-----------"
				;----
				; if there aren't any items given at this point, create an empty one... 
				; this allows us to simply append to the system later.
				unless string? content* group/aspects/text [
					vprint "NO TEXT... initializing to an empty text"
					;fill* group/aspects/text copy ""
				]
				vout
				group
			]
			
			
			
			;-----------------
			;-        fasten()
			;-----------------
			fasten: funcl [
				group
			][
				vin [{!scrolled-list/fasten()}]
				;--------------------------------
				; shortcuts for simpler coding
				;--------------------------------
				edtr: group/editor-marble
				mtrl:  edtr/material
				spct:  edtr/aspects
				hscrl: group/hscroller-marble
				vscrl: group/vscroller-marble
				
				vprint content edtr/aspects/text
				vprint content group/aspects/text
				
				;pipe* edtr/aspects/text group/aspects/text
				group/aspects/text: edtr/aspects/text
				
				
				;--------------------------------
				; link-up the text scrollbars
				;--------------------------------
				link/reset hscrl/aspects/maximum mtrl/longest-line
				link/reset hscrl/aspects/visible mtrl/visible-length
				attach/to spct/left-off hscrl/aspects/value 'value
				fill vscrl/aspects/value 0
				
				
				link/reset vscrl/aspects/maximum mtrl/number-of-lines
				link/reset vscrl/aspects/visible mtrl/visible-lines
				attach/to spct/top-off vscrl/aspects/value 'value ; bridged value!
				fill vscrl/aspects/value 0

				vout
			]
		]
	]
]
