REBOL [
	; -- Core Header attributes --
	title: "Glass list style marble"
	file: %style-list.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {Allows single and multi-selection of items within a provided bulk, presented within a single list of text.}
	web: http://www.revault.org/modules/style-list.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-list
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-list.r

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
		The list style will go through a revamping at some point, but it works well-enough as-is.
		
		In the future, the aspects should not change much, but I do expect to rename the 'list aspect
		to 'items.  This is to make it more consistent with the other styles which handle bulk table inputs.
		
		Also note that when the theme engine will be implemented and !style-list upgraded, the 
		visual aspects will all be removed and put within the theme system.
	}
	;-  \ documentation
]




slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [
		!glob to-color
	]
		
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

	slim/open/expose 'glue none [ !empty? !filled?]

	
	sillica-lib: slim/open/expose 'sillica none [
		get-aspect
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
		do-event
		do-action
		new-bulk-list
	]
	epoxy-lib: epoxy: slim/open/expose 'epoxy none [ !box-intersection ]
	event-lib: slim/open 'event none
	
	slim/open/expose 'utils-series  none [ include ]
	slim/open/expose 'utils-blocks  none [ include-different find-same ]
	
	slim/open/expose 'bulk none [
		is-bulk? symmetric-bulks? get-bulk-property   
		set-bulk-property set-bulk-properties  search-bulk-column filter-bulk 
		get-bulk-row bulk-columns bulk-rows copy-bulk sort-bulk insert-bulk-records 
		;append-bulk-records 
		make-bulk clear-bulk 
	]


	;--------------------------------------------------------
	;-   
	;- !LIST [ ]
	!list: make marble-lib/!marble [
	
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
			
			;-        selectable?:
			;
			; when set to false, clicking on the list doesn't select anything.
			;
			; this doesn't affect the currently chosen or visible items.  it simply deactivates clicking.
			;
			; there is no visual cue either. (you can chagne the bg color if you want to indicate a different state)
			selectable?: true
			
			;-        color:
			; color of bg
			color: white 
			
			;- 		LIST SPECIFICS
			;-        list:
			list: make-bulk/records 3 [ "" [] "" ]
;			list: [
;				"New Brunswick123456789" 00
;				"New York" 11
;				"Montreal" 22 
;				"L.A." 33
;				"L.A." 37 ; tests similar labels in the list
;				"Paris" 44
;				"London 23iwuety eoitetoiu" 55
;				"Rome" 66
;				"Pekin" 77
;				"Chicago" 88
;				"Amsterdam" 99
;				"Monza" 1010
;				"Mexico City" 1111
;				"Bangkok" 1212
;			]
			
			;-        columns:
			; how many columns in list data?
			;
			; for now this is hard-set to 2, but in future versions, we will expand and allow several label columns.
			columns: 2
			
			;-        list-index:
			; at what item should the display start showing list items?
			list-index: 1
			
			;-        chosen:
			; this is the list of chosen items in the list.
			; note:  
			;     -items in this list MUST be the exact SAME strings as those in list (not similar copies)
			;     -this list is managed by the events, so don't expect it to stay as-is.
			;     -by default the list is single select but is can be switched to multi-select by setting multi-choose? to true in the !list object.
			;    
			chosen: []
			
			;-        leading:
			; space between lines.
			leading: 6
		]

		
		;-    Material[]
		material: make material [
			;--------------------------
			;-        fill-weight:
			; we benefit from extra vertical space.
			;--------------------------
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
			;--------------------------
			visible-items: none
			
			;--------------------------
			;-        row-count:
			; returns the number of items in list.
			;--------------------------
			row-count: none
			
			;--------------------------
			;-        chosen-items:
			;
			; a version of list with only the chosen in it.
			;
			; it can be used directly as the source of another list !
			;
			chosen-items: none
			
			;--------------------------
			;-        chosen?:
			;
			; when any selection is active, this turns true.
			;
			; should be used to toggle other plugs based on selection.
			;--------------------------
			chosen?: none
			
			;--------------------------
			;-        discarded?:
			;
			; OPPOSITE OF CHOSEN?
			; 
			; when NO selection is active, this turns true.
			;
			; should be used to toggle other plugs based on selection.
			;--------------------------
			discarded?: none
		]
		
		
		;-    multi-choose?:
		multi-choose?: true
		
		
		;-    actions:
		; nothing by default
		actions: context [
;			list-picked: func [event][
;				;print "list action!"
;				;print event/picked
;				;probe event/picked-data
;				;probe event/chosen
;			]
		]
		
		
		;-    list-columns:
		list-columns: 2 ; eventually programmable
		
		;-    scroller:
		; stores the scroller we allocate for our own internal use.
		scroller: none
		
		;-    filter-mode-plug:
		; just a simple plug which stores chosen filter mode.
		; for now, only 'same is supported or really usefull.
		;
		; in special circumstance, though, you could require 'simple.
		filter-mode-plug: none
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'list  
			
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
						color !color  
						focused? !bool 
						hover? !bool 
						selected? !bool
						
						; list specific
						list !block ; tag pairs of "label" payload
						list-index !integer
						chosen !block ; one or more chosen items.
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
						position dimension color focused? selected? list list-index chosen
						[
							(
								d: data/dimension=
								p: data/position=
								e: d + p - 1x1
								list: data/list=
								[]
							)
							
							
;							(
;								;shadows
;								prim-cavity/colors
;									data/position= 
;									data/dimension= - 1x1
;									white
;									theme-border-color
;							)
							fill-pen (data/color= ) ;* .98)
							pen none; theme-knob-border-color
							box (p) (e)  
							
							; labels
							pen none
							fill-pen black
							line-width 0.5
							(
								prim-list/arrows p + 2x2 d - 5x5 theme-list-font content* gel/glob/marble/aspects/leading list data/list-index= data/chosen= none black
							)
							
							; for debugging
;							pen 255.0.0
;							fill-pen none
;							box (p + 2x2) (e - 2x2)
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
				
				;v?? i
				; 2x4 is a hard-coded origin where drawing starts
				picked: second coordinates - 2x4
				picked: (to-integer (picked / (theme-list-font/size + content* list/aspects/leading)))
				picked: picked + i ;+ 2
				;v?? picked
				
				vout
				
				picked
			]
			
			
						
			
			
			
			;-----------------
			;-        find-row()
			;
			; return the row at the index of supplied item
			;
			; note: when supplying a string it must be the EXACT same string, cause a single list
			;       might have several items with the same label
			;
			;-----------------
			find-row: func [
				list [object!]
				item [string! integer!]
				/local items columns label-column row
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/find-item()}]
				items: content* list/aspects/list
				
				row: either string? item [
				;	item: pick items (item - 1 * columns + 1)
					column: any [
						get-bulk-property items 'label-column
						1
					]
					search-bulk-column/same/row items column item
				][
					; if item is larger than row count, none is returned
					get-bulk-row items item
				]

				vout				
				; we ignore invalid pick values
;				if item: find-same items item [
;					item
;				]

				row
			]
			

			;--------------------------
			;-        clear-list()
			;--------------------------
			; purpose:  when the list item is the owner/main manipulator of data, we can let IT it clear the list.
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    you should not use this when the list is linked to a source.
			;			this also clears the selection.
			;
			; to do:    
			;
			; tests:    
			;--------------------------
			clear-list: funcl [
				list [object!]
			][
				vin "clear-list()"
				
				blk: content list/aspects/list
				clear-bulk blk
				dirty list/aspects/list
				
				blk: content list/aspects/chosen
				clear blk
				dirty list/aspects/chosen
				
				vout
			]
			
			;-----------------
			;-        choose-item()
			;
			; add the item (if its in list) to the chosen block.
			;
			; note:
			;     -if item doesn't exist its quietly ignored 
			;     -if item doesn't change the list, no liquid messaging occurs.
			;-----------------
			choose-item: func [
				list [object!]
				item [string! none!] "none CLEARs the chosen list"
				/add "add this to chosen, don't replace it, only valid if list/multi-choose? = true "
				/remove "remove this item instead of adding it."
				/local c l cplug
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/choose-item()}]
				cplug: get-aspect/plug list 'chosen 
				c: content* cplug
				l: get-aspect list 'list
				either none? item [
					clear c
					cplug/valve/notify cplug
				][
					if find-same l item [
						either remove [
							system/words/remove find c item
							cplug/valve/notify cplug
						][
							either all [
								add
								list/multi-choose?
							][
								;vprint "MULTI!"
								; only change list if item isn't already in it
								unless find-same c item [
									; multi-choose (add new item to chosen)
									include-different c item
									
									; make sure liquid notifies any linked or piped plugs
									cplug/valve/notify cplug
								]
							][
								;vprint "single choose"
								; only change list if item isn't already in it OR chosen has more than one item in it
								unless all [
									1 = length? c
									find-same c item
								][
									; single choose (replace any chosen by new item)
									clear c
									append c item
								
									; make sure liquid notifies any linked or piped plugs
									cplug/valve/notify cplug
								]
							]
						]
					]
				]
				
				vout
			]
			
			
			;--------------------------
			;-        delete-chosen()
			;--------------------------
			; purpose:  if the list has any chosen items, it deletes them from the list.
			;
			; inputs:   
			;
			; returns:  
			;
			; notes:    the chosen list is cleared after
			;
			; to do:    
			;
			; tests:    
			;--------------------------
			delete-chosen: funcl [
				list [object!]
			][
				vin "delete-chosen()"
				cplug: get-aspect/plug list 'chosen 
				lplug: get-aspect/plug list 'list
				c: content* cplug
				l: content* lplug
				
				remove-each [label tmp data] next l [
					all [
						blk: find c label
						same? label pick blk 1
					]
				]
				
				list/valve/choose-item list none
				lplug/valve/notify lplug
				
				vout
			]
			
			
			;-----------------
			;-        pick-next()
			;
			; the list is automatically scrolled so that the item is visible
			;-----------------
			pick-next: func [
				list
				/wrap "cause the last item to chose the first"
				/data "returns the data row instead of the label"
				/local item  c l cplug spec list-spec row new-item blk
			][
				vin [{pick-next()}]
				cplug: get-aspect/plug list 'chosen 
				c: content* cplug
				l: get-aspect list 'list

				item: any [
					all [
						not empty? c
						last c
					]
					;pick l 2 ; if nothing is currently picked, get the first label.
				]
				
				
				list-spec: first l
				
				; get row data for current item
				blk: find-same l item
				
				new-item: any [
					all [
						blk
						pick blk: skip blk 3 1
					]
					; we are at end
					all [
						any [wrap  not blk]
						pick l 2
					]
				]
				
				if new-item [
					choose-item list new-item
					if data [
						if (blk: find-same l new-item) [
							row: copy/part blk 3
						]
						new-item: row
					]
				]
				vout
				new-item
			]
			
			;-----------------
			;-        pick-previous()
			;
			; the list is automatically scrolled so that the item is visible
			;-----------------
			pick-previous: func [
				list
				/wrap "cause the first item to chose the last"
				/data "returns the data row instead of the label"
				/local item  c l cplug spec list-spec row new-item blk
			][
				vin [{pick-previous()}]
				cplug: get-aspect/plug list 'chosen 
				c: content* cplug
				l: get-aspect list 'list

				item: any [
					all [
						not empty? c
						last c
					]
					;pick l 2 ; if nothing is currently picked, get the first label.
				]
				
				
				list-spec: first l
				
				; get row data for current item
				blk: find-same l item
				
				new-item: any [
					all [
						blk
						(index? blk) > 4
						pick blk: skip blk -3 1
					]
					; we are at head
					all [
						any [wrap  not blk]
						(length? l) > 4 ; no point in picking the same item again
						pick tail l -3
					]
				]
				
				if new-item [
					choose-item list new-item
					if data [
						if (blk: find-same l new-item) [
							row: copy/part blk 3
						]
						new-item: row
					]
				]
				
				vout
				new-item
			]
			
			
			
			;--------------------------
			;-        pick-string()
			;--------------------------
			; purpose:  picks all items with have a string equal to given string!
			;
			; returns:  nothing for now.
			;--------------------------
			pick-string: funcl [
				list [object!]
				label [string!]
				;/sub-string "also match if given label is PART of list's item list"
			][
				vin "pick-string()"
				ch-plug: list/aspects/chosen 
				ch-items: content* ch-plug
				items: copy next content* list/aspects/list

				remove-each [lbl spec data] items [
					lbl <> label
				]
				
				;---
				; keep only labels, cause we put this within chosen-items
				lbls: extract items 3

				clear ch-items
				append  ch-items  lbls
				ch-plug/valve/notify ch-plug
				
				vout
				
				either empty? items [
					none
				][
					items
				]
			]

			
			
			
			;-----------------
			;-        list-handler()
			;
			;-----------------
			list-handler: func [
				event [object!]
				/local list picked i l data-col label-col
			][
				vin [{HANDLE LIST EVENTS}]
				;vprint event/action
				list: event/marble
				switch/default event/action [
					start-hover [
						fill* list/aspects/hover? true
					]
					
					end-hover [
						fill* list/aspects/hover? false
					]
					
					select [
						;-----------------
						; converts mouse click into list item selection event.
						;-----------------
						;vprint "RESOLVING CHOSEN ITEM"
						fill* list/aspects/selected? true ; this is not use directly by this marble's graphics.
						if all [
							content event/marble/aspects/selectable?
							picked: item-from-coordinates list event/offset 
						][
							;v?? picked
						
							if picked: find-row list picked [
								;probe content* list/aspects/chosen
								
								event-lib/queue-event make event compose/only [
									action: 'list-picked
									picked: (first picked)
									; we now return the whole row of list, since it may contain user data beyond
									; what the list marble requires.
									picked-data: (picked)
									chosen: (content* list/aspects/chosen)
								]
							]
						]
					]
					
					CONTEXT-PRESS [
						if picked: item-from-coordinates list event/offset [
							if picked: find-row list picked [
								event-lib/queue-event make event compose/only [
									action: 'list-context-start
									picked: (first picked)
									; we now return the whole row of list, since it may contain user data beyond
									; what the list marble requires.
									picked-data: (picked)
									chosen: (content* list/aspects/chosen)
								]
							]
						]
					]

					list-picked [
						; if list doesn't mave multi-choose? enabled, it will ignore /add and replace chosen.
						either event/control? [
							;vprint "-----------> MULTI CHOOSE"
							;probe event/picked
							either find content event/marble/aspects/chosen event/picked [
								list/valve/choose-item/remove list event/picked
							][
								list/valve/choose-item/add list event/picked
							]
						][
							list/valve/choose-item list event/picked
						]
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
				list
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/materialize()}]
				
				list/material/row-count: liquify* epoxy/!bulk-row-count
				
				; this plug expects to be linked, never piped
				;-           visible-items:
				list/material/visible-items: liquify*/with !plug [
					; we store a reference to the list in which this plug is used
					list-marble: list
					
					valve: make valve [
						type: 'list-visibility-calculator
						
						;-----------------
						;-                process()
						;-----------------
						process: func [
							plug
							data
							/local list dimension v leading
						][
							vin [{visibility-calculator/process()}]
							
							; just make sure we have a proper interface
							plug/liquid: either all [
								block? list: pick data 1
								pair? dimension: pick data 2
								integer? leading: pick data 3
							][
								v: plug/list-marble/valve
								to-integer min ( bulk-rows list)((dimension/y - 6) / (theme-list-font/size + leading))
							][
								0
							]
							vout
						]
					]
				]
				
				list/material/chosen-items: liquify* epoxy/!bulk-filter
				list/filter-mode-plug: liquify*/fill !plug 'same
				
				list/material/discarded?: liquify*/link !empty?  list/aspects/chosen
				list/material/chosen?:    liquify*/link !filled? list/aspects/chosen

				vout
			]
			

			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				list
			][
				vin [{glass/!} uppercase to-string list/valve/style-name {[} list/sid {]/fasten()}]
				
				link*/reset list/material/visible-items reduce [list/aspects/list list/material/dimension list/aspects/leading]
				link list/material/row-count list/aspects/list
				link list/material/row-count list/aspects/columns
				
				link*/reset list/material/chosen-items list/aspects/list
				link* list/material/chosen-items list/aspects/chosen
				link* list/material/chosen-items list/filter-mode-plug
				
				
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
			specify: funcl [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				;/local data pair-count tuple-count block-count
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/specify()}]
				
				pair-count: 0
				tuple-count: 0
				block-count: 0
				
				parse spec [
					any [
						copy data ['with block!] (
							do bind/copy data/2 marble 
						) 
						
						| '.bulk set data block! (
							fill* marble/aspects/list data
						)
						
						| '.list set data block! (
							blk: make-bulk 3
							foreach item data [
								append blk reduce [ form :item  copy [ ]  :item ]
							]
							fill* marble/aspects/list  blk
							blk: none
						)
						
						| '.non-selectable (fill* marble/aspects/selectable? false)
						
						| 'stiff (fill* marble/material/fill-weight 0x0)
						
						| 'stretch set data pair! (fill* marble/material/fill-weight data)
						
						| set data tuple! (
							tuple-count: tuple-count + 1
							switch tuple-count [
								1 [set-aspect marble 'label-color data]
								2 [set-aspect marble 'color data]
							]
							
							set-aspect marble 'color data
						)
						
						| set data pair! (
							pair-count: pair-count + 1
							switch pair-count [
								1 [	fill* marble/material/min-dimension data ]
								2 [	set-aspect marble 'offset data ]
							]
						)
						
						| set data string! ( fill* marble/aspects/label data )
						
						| set data block! (
							block-count: block-count + 1
							switch block-count [
								1 [
									; lists support 3 or more columns, one being label, another options and the last being data.
									; options will change how the item is displayed (bold, strikethru, color, etc).
									fill* marble/aspects/list make-bulk/records 3 data
								]
								2 [
									if object? get in marble 'actions [
										marble/actions: make marble/actions [list-picked: make function! [event] bind/copy data marble]
									]
								]
							]
						)
						
						| skip 
					]
				]
				
				
				;----
				; if there aren't any items given at this point, create an empty one... 
				; this allows us to simply append to the system later.
				unless block? content* marble/aspects/list [
					
					fill* marble/aspects/list new-bulk-list
				]
				
				
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
