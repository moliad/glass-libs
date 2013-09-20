REBOL [
	; -- Core Header attributes --
	title: "Glass tree list marble"
	file: %style-tree.r
	version: 0.1.0
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "core list tree style for GLASS."
	web: http://www.revault.org/modules/style-tree.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-tree
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-tree.r

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
		v0.1.0 - 2013-09-17
			-License changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		The tree style is not yet finished, it was under research in order to handle 
		a minimum of 100000 items in real time.
		
		It has yet to have input handling or even display.  It may be replaced completely, at any time.
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'style-tree
;
;--------------------------------------

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
		formulate
	]
	
	sillica-lib: slim/open/expose 'sillica none [
		get-aspect
		find-same
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-cavity
		prim-x
		prim-label
		prim-list
		prim-glass
		top-half
		bottom-half
		do-event
		do-action
		new-bulk-list
	]
	epoxy-lib: epoxy: slim/open/expose 'epoxy none [ !box-intersection !list-visibility-calculator ]
	event-lib: slim/open 'event none
	
	icon-lib:  slim/open/expose 'icons none   [  get-icon  load-icons  ]
	

	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;
	;--------------------------------------------------------
	load-icons/size 16
	

	;--------------------------
	;-    !item-manager:
	;
	; the base object for any type of tree list item
	;--------------------------
	!item-manager: context [
		;--------------------------
		;-        type:
		;--------------------------
		type: none
		
		;--------------------------
		;-         icon:
		;
		; icon used in display
		;--------------------------
		icon: none
		
		
		
		
		;--------------------------
		;-         display()
		;--------------------------
		; purpose:  generate the agg block which will be accumulated as a big list.
		;
		; inputs:   an item from the list-parser
		;
		; returns:  
		;
		; notes:    the data given by the list-parser should be enough to determine all aspects 
		;           of display which aren't concerned with
		;
		; tests:    
		;--------------------------
		display: funcl [
			marble [object!] "The tree-list marble"
			item [block!] "an item from the list-parser.  Do not assume the outer block isn't shared or cleared. Though the internals should be safe (we use references as much as possible to lower RAM usage)"
		][
			vin "display()"
			
			vout
		]
		
		
		
		
		;--------------------------
		;-         list-parser()
		;--------------------------
		; purpose:  given a data block, will generate a flat list of items to draw, by calling display()
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		list-parser: funcl [
		][
			vin "list-parser()"
			
			vout
		]
		
		
		
		
		
		

		;-----------------
		;-        handle()
		;
		; whenever an event occurs within the tree box, 
		; it is sent to that item's handler.
		;-----------------
		list-handler: func [
			event [object!]
			/local list picked i l data-col label-col
		][
			vin [{HANDLE LIST EVENTS}]
			vprint event/action
			
			vprint [type " handler"]
			
			list: event/marble
			switch/default event/action [
				start-hover [
					vprint rejoin [ "hover " content event/item/1 ]
				]
				
				
				end-hover [
					;fill* list/aspects/hover? false
				]
				
				
				open [
					vprint rejoin [ "open " content event/item/1 ]
					
				]
				
				
				close [
					vprint rejoin [ "close " content event/item/1 ]
				]
				
				
				select [
;					;vprint "RESOLVING SELECTED ITEM"
;					if picked: item-from-coordinates list event/offset [
;					;v?? picked
;					
;						if picked: find-row list picked [
;							;probe content* list/aspects/selected
;							
;							event-lib/queue-event make event compose/only [
;								action: 'list-picked
;								picked: (first picked)
;								; we now return the whole row of list, since it may contain user data beyond
;								; what the list requires.
;								picked-data: (picked)
;								selected: (content* list/aspects/selected)
;							]
;						]
;					]
				]
			]
		]
	]
			
	
;	
;	;--------------------------
;	;-     tree-flatener:
;	;
;	; this plug is used to convert the tree from a hierachy to a flat list able to be displayed.
;	; 
;	;--------------------------
;	slim/von
;	tree-flatener: formulate !plug [
;		gogo: 9
;		
;		
;		;--------------------------
;		;-         process()
;		;--------------------------
;		; purpose:  
;		;
;		; inputs:   
;		;
;		; returns:  
;		;
;		; notes:    
;		;
;		; tests:    
;		;--------------------------
;		process: funcl [
;			plug
;			data
;		][
;			vin "process()"
;			
;			vout
;		]
;		
;	]
;	
;	ask "55"



	;--------------------------------------------------------
	;-   
	;- !TREE-LIST[ ]
	!tree-list: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: context [
			;-        offset:
			offset: -1x-1
			
			
			;-        focused?:
			focused?: false


			;-        hover?:
			hover?: false
			
			
			;-        selected?:
			selected?: false
			
			
			;-        color:
			; color of bg
			color: white * .8
			
			
			;-        item-handlers:
			item-handlers: reduce [
				'a make !tree-list [ type: 'a ]
				
				'b make !tree-list [ type: 'b ]
			]
			
			
			;----
			;-        tabs:
			;----
			; columnar tab stops for any column creating items.
			;
			; this can be an integer, meaning all columns have the same width
			; or each column can be specified individually using a list of integers within a block.
			;
			; note that when there are more columns than tabs, the extra columns
			; are simply spaced by some fixed amounts which effectively breaks the aligned column display
			;
			tabs: 50
			
			
			;-        list-index:
			; at what item should the display start showing list items?
			list-index: 1
			
			
			;-        leading:
			; space adjustment between lines.
			leading: 6
			
			
			;-        selected:
			; a block of strings which list which are to be considered selected
			;
			; note:  
			;     -items in this list MUST be the exact SAME strings as those in list (not similar copies)
			;     -this list is managed by the events, so don't expect it to stay as-is.
			;     -by default the list is single select but is can be switched to multi-select by setting multi-choose? to true in the !list object.
			;     -the list is not a bulk, but a simple block of strings    
			;
			;     -is called chosen in list style
			selected: []
			
			
			;--------------------------
			;-        items:
			;
			; a hierarchical list of items. may have multiple columns.
			;
			; each type has its own parse setup, callbacks and display driver.
			;--------------------------
			items: [
				!type "root" "root" .open [
					!type "child" "child" .close 
					!type "child" "child" .close
					!type "a" "v"  [
					]
					!type "child" "child" .close 
				]
			]
		]

		
		;-    Material[]
		material: make material [
			;--------------------------
			;-        fill-weight:
			; we benefit from extra vertical space.
			fill-weight: 1x1
			
			;--------------------------
			;-        visible-items:
			;
			; returns how many items CAN be shown in the list, not how many are currently visible.
			;
			; this is based on the list size, list/valve/list-font/size, list/valve/item-spacing, and dimension, but doesn't react to list-index.
			;
			; if length? of list is smaller than size of list-box, visible-items will shrink to it.
			; 
			visible-items: none
			
			;--------------------------
			;-        row-count:
			; returns the number of items in list.
			row-count: none
			
			;--------------------------
			;-        selected-items:
			;
			; a version of list with only the selected in it.
			;
			; it can be used directly as the source of another list !
			;
			selected-items: none
			

		]
		
		
		;--------------------------
		;-    header-group:
		;
		; links to a group spec which is used to build up the style.  
		; the number of items in the group defines the number of columns expected from the hierarchy data.
		;
		; if the data is a block, then it is used as the spec for the group frame.
		;
		; if its an allocated frame (horizontal), then we attach to it .
		;
		; once the group is allocated, we will look at its collection to determine number of columns.
		;
		; if the header-group is none, there is no header and we expect only one (unnamed) column.
		;--------------------------
		header-group: none
		
		
		
		
		;-    multi-select?:
		multi-select?: true
		
		
		
		
		
		;-    actions:
		; nothing by default
		actions: context [
			;list-picked: func [event][
				;print "list action!"
				;print event/picked
				;probe event/picked-data
				;probe event/selected
			;]
		]
		
		
		;-    list-columns:
		list-columns: 2 ; eventually programmable
		
		
		;-    scroller:
		; stores the scroller we allocate for our own internal use.
		scroller: none
		
		
		;-    filter-mode-plug:
		; just a simple plug which stores selected filter mode.
		; for now, only 'same is supported or really usefull.
		;
		; in special circumstance, though, you could require 'simple.
		filter-mode-plug: none
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'tree-list  
			
			
			;-        item-spacing:
			; how much space to add between items.  (not yet fully supported, some things are still hard coded to: 2)
			item-spacing: 2
			
			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				pos: none
				
				
				valve: make valve [
					; internal calculation vars
					p: none
					d: none
					e: none
					h?: none
					list: none
					highlight-color: 0.0.0.50
					
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						focused? !bool 
						hover? !bool 
						selected? !bool
						
						; list specific
						list !block ; tag pairs of "label" payload
						list-index !integer
						selected !block ; one or more selected items.
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
						position dimension color focused? selected? list list-index selected
						[
							
							(
								d: data/dimension=
								p: data/position=
								e: d + p - 1x1
								;h?: data/hover?= 
								list: data/list=
								[]
							)
							
							
							(
								;shadows
								prim-cavity/colors
									data/position= 
									data/dimension= - 1x1
									white
									theme-border-color
							)
							
							
							; labels
							pen none
							fill-pen black
							line-width 0.5
							(
								prim-list p + 2x2 d - 5x5 theme-list-font content* gel/glob/marble/aspects/leading list data/list-index= data/selected= none black
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
			;-        item-from-coordinates()
			;
			; returns the index of item under coordinates
			;-----------------
			item-from-coordinates: func [
				list [object!]
				coordinates [pair!]
				/local i picked
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/item-from-coordinates()}]
				i: content* list/aspects/list-index
				
				v?? i
				; 2x4 is a hard-coded origin where drawing starts
				picked: second coordinates - 2x4
				picked: (to-integer (picked / (theme-list-font/size + content* list/aspects/leading)))
				picked: picked + i ;+ 2
				;v?? picked
				
				vout
				
				picked
			]
			
			
			
			
			
			
			
;			;-----------------
;			;-        find-row()
;			;
;			; return the row at the index of supplied item
;			;
;			; note: when supplying a string it must be the EXACT same string, cause a single list
;			;       might have several items with the same label
;			;
;			;-----------------
;			find-row: func [
;				list [object!]
;				item [string! integer!]
;				/local items columns label-column row
;			][
;				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/find-item()}]
;				items: content* list/aspects/list
;				
;				row: either string? item [
;				;	item: pick items (item - 1 * columns + 1)
;					column: any [
;						get-bulk-property items 'label-column
;						1
;					]
;					search-bulk-column/same/row items column item
;				][
;					; if item is larger than row count, none is returned
;					get-bulk-row items item
;				]
;
;				vout				
;				; we ignore invalid pick values
;;				if item: find-same items item [
;;					item
;;				]
;
;				row
;			]
			
					
			
			
			;-----------------
			;-        list-handler()
			;
			;-----------------
			list-handler: func [
				event [object!]
				/local list picked i l data-col label-col
			][
				vin [{HANDLE LIST EVENTS}]
				vprint event/action
				list: event/marble
				switch/default event/action [
					start-hover [
						fill* list/aspects/hover? true
					]
					
					end-hover [
						fill* list/aspects/hover? false
					]
					
					select [
;						;vprint "RESOLVING SELECTED ITEM"
;						if picked: item-from-coordinates list event/offset [
;						;v?? picked
;						
;							if picked: find-row list picked [
;								;probe content* list/aspects/selected
;								
;								event-lib/queue-event make event compose/only [
;									action: 'list-picked
;									picked: (first picked)
;									; we now return the whole row of list, since it may contain user data beyond
;									; what the list requires.
;									picked-data: (picked)
;									selected: (content* list/aspects/selected)
;								]
;							]
;						]
					]

					list-picked [
;						; if list doesn't mave multi-choose? enabled, it will ignore /add and replace selected.
;						either event/control? [
;							;vprint "-----------> MULTI CHOOSE"
;							choose-item/add list event/picked
;						][
;							choose-item list event/picked
;						]
						
					]
										
					; successfull click
					release [
						fill* list/aspects/selected? false
						;do-action event
					]
					
					; canceled mouse release event
					drop no-drop [
						fill* list/aspects/selected? false
						;do-action event
					]
					
					swipe [
						fill* list/aspects/hover? true
						;do-action event
					]
				
					drop? [
						fill* list/aspects/hover? false
						;do-action event
					]
					
					
					scroll focused-scroll [
						vprint event/direction
						switch event/direction [
							pull [
								i: get-aspect event/marble 'list-index
								l: get-aspect/or-material event/marble 'row-count
								v: get-aspect/or-material event/marble 'visible-items
								if (i + v - 1) < (l) [
									fill* event/marble/aspects/list-index i + event/amount
								]
							]
							
							push [
								i: get-aspect event/marble 'list-index
								if i > 1 [
									fill* event/marble/aspects/list-index i - event/amount
								]
							]
						]
					]
					
					
					focus [
;						event/marble/label-backup: copy content* event/marble/aspects/label
;						if pair? event/coordinates [
;							set-cursor-from-coordinates event/marble event/coordinates false
;						]
;						fill* event/marble/aspects/focused? true
					]
					
					unfocus [
;						event/marble/label-backup: none
;						fill* event/marble/aspects/focused? false
					]
					
					text-entry [
;						type event
					]
				][
					vprint "IGNORED"
				]
				
				; totally configurable end-user event handling.
				; not all actions are implemented in the actions, but this allows the user to 
				; add his own events AND his own actions and still work within the API.
				do-event event
				
				vout
				none
			]
			
			
			;-----------------
			;-        materialize()
			; 
			; <TO DO> make a purpose built epoxy plug for visible-items and instantiate it.
			;-----------------
			materialize: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/materialize()}]
				
				marble/material/row-count: liquify* epoxy/!bulk-row-count
				
				; this plug expects to be linked, never piped
				;-           visible-items:
				marble/material/visible-items: liquify* !list-visibility-calculator
				
;				marble/material/visible-items: liquify*/with !plug [
;					; we store a reference to the marble in which this plug is used
;					;list-marble: marble
;					
;					valve: make valve [
;						type: 'list-visibility-calculator
;						
;						;-----------------
;						;-                process()
;						;-----------------
;						process: func [
;							plug
;							data
;							/local marble dimension v leading
;						][
;							vin [{visibility-calculator/process()}]
;							
;							; just make sure we have a proper interface
;							plug/liquid: either all [
;								block? marble: pick data 1
;								pair? dimension: pick data 2
;								integer? leading: pick data 3
;							][
;								;v: plug/list-marble/valve
;								to-integer min ( bulk-rows marble)((dimension/y - 6) / (theme-list-font/size + leading))
;							][
;								0
;							]
;							;print ["visible-items: " plug/liquid]
;							vout
;						]
;					]
;				]
				
				marble/material/selected-items: liquify* epoxy/!bulk-filter
				marble/filter-mode-plug: liquify*/fill !plug 'same
				
				
				vout
			]
			

			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/fasten()}]
				
;				link*/reset tree/material/visible-items reduce [tree/material/items tree/material/dimension tree/aspects/leading]
;				link tree/material/row-count tree/material/items
;				link tree/material/row-count tree/aspects/columns
;				
;				link*/reset tree/material/selected-items tree/material/items
;				link* tree/material/selected-items tree/aspects/selected
;				link* tree/material/selected-items tree/filter-mode-plug
				
				
				vout
			]
			
			
			
			;-----------------
			;-        specify()
			;
			; parse a specification block during initial layout operation
			;
			; can also be used at run-time to set values in the aspects block directly by the application.
			;
			; but be carefull, as some attributes are very heavy to use like frame sub-marbles, which will 
			; effectively trash their content and rebuild the content again, if used blindly, with the 
			; same spec block over and over.
			;
			; the marble we return IS THE MARBLE USED IN THE LAYOUT
			;
			; so the the spec block can be used to do many wild things, even change the 
			; marble type on the fly!!
			;-----------------
			specify: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				/local data pair-count tuple-count block-count val blk
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/specify()}]
				
				pair-count: 0
				tuple-count: 0
				block-count: 0
				
				parse spec [
					any [
						copy data ['with block!] (
							;marble: make marble data/2
							;liquid-lib/reindex-plug marble
							do bind/copy data/2 marble 
							
						) | 
						'stiff (
							fill* marble/material/fill-weight 0x0
						) |
						'stretch set data pair! (
							fill* marble/material/fill-weight data
						) |
						set data tuple! (
							tuple-count: tuple-count + 1
							switch tuple-count [
								1 [set-aspect marble 'label-color data]
								2 [set-aspect marble 'color data]
							]
							
							set-aspect marble 'color data
						) |
						set data pair! (
							pair-count: pair-count + 1
							switch pair-count [
								1 [	fill* marble/material/min-dimension data ]
								2 [	set-aspect marble 'offset data ]
							]
						) |
						
						
						;-----------------
						; header setup
						;-----------------
;						'.header set data block! (
;							vprint "found header group specification"
;							marble/header-group: compose/only [
;								row tight (data)
;							]
;						)
						
						'.titles set data block! (
							vprint "found header titles"
							 blk: copy []
							parse data [
								any [
									set val string! (append blk reduce [ 'text (val) ])
									| skip
								]
							]	
							fill* marble/aspects/titles blk
							fill* marble/aspects/columns length? blk
						)
						
						
						set data string! (
							;----
							; eventually, strings could add root list items directly.
							;----
							;fill* marble/aspects/label data
						) |
						
						
						set data block! (
							block-count: block-count + 1
							switch block-count [
								1 [
									vprint "found hierarchical dataset"
									fill* marble/aspects/items data
								]
								2 [
									if object? get in marble 'actions [
										vprint "found trigger action(s)"
										marble/actions: make marble/actions [list-picked: make function! [event] bind/copy data marble]
									]
								]
							]
						) |
						skip 
					]
				]
				
				
				;----
				; if there aren't any items given at this point, create an empty one... 
				; this allows us to simply append to the system later.
				unless block? content* marble/aspects/items [
					fill* marble/aspects/items copy []
				]
				
				vprobe marble/header-group
				
				vout
				marble
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
				list
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/stylize()}]
				
				; just a quick stream handler for our list
				event-lib/handle-stream/within 'list-handler :list-handler list
				
				
				vout
			]
		]
	]
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

