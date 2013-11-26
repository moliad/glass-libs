REBOL [
	; -- Core Header attributes --
	title: "Glass drop list marble"
	file: %style-droplist.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: "Droplist pane style for glass."
	web: http://www.revault.org/modules/style-droplist.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-droplist
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-droplist.r

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
		The droplist is a style which displays items in a list.  Its mainly used by
		popups which have to show a list of items.
		
		its a faster subset of the list style.
		
		it may only have one picked item as opposed to the list style which allows multiple selection.
		
		its min-width aspect allows you to force the width of the list to be larger than the width
		of the smallest text in the items.
		
		note that most materials and aspects are not calculated more than once per change in items
		since they are all lazy and much of the calculation is stored in the labels-analysis plug.
		
		this makes the droplist very quick to refresh, since it doesn't need to recalculate anything
		beyond putton the pane and its text on screen.
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
		get-aspect
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		label-dimension
		prim-bevel
		prim-x
		prim-label
		prim-list
		prim-glass
		prim-item-stack
		top-half
		bottom-half
		do-event
	]
	epoxy-lib: epoxy: slim/open/expose 'epoxy none [ !box-intersection ]
	event-lib: slim/open 'event none
	slim/open/expose 'utils-blocks  none [  find-same ]

	slim/open/expose 'bulk none [
		is-bulk? symmetric-bulks? get-bulk-property get-bulk-label-column get-bulk-labels-index 
		set-bulk-property set-bulk-properties bulk-find-same search-bulk-column filter-bulk 
		get-bulk-row bulk-columns bulk-rows copy-bulk sort-bulk insert-bulk-records add-bulk-records 
		make-bulk clear-bulk 
	]
	


	;--------------------------------------------------------
	;-   
	;- !DROPLIST[ ]
	!droplist: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: make aspects [
		
		
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
			
			;- 		droplist SPECIFICS
			;-        items:
			items: make-bulk/properties/records 3 [
				label-column: 1
			][
				"New Brunswick123456789" [] 00
				"New York" [] 11
				"Montreal" [] 22 
				"L.A." [] 33
				"L.A." [] 37 ; tests similar labels in the droplist
				"Paris" [] 44
				"London 23iwuety eoitetoiu" [] 55
				"Rome" [] 66
				"Pekin" [] 77
				"Chicago" [] 88
				"Amsterdam" [] 99
				"Monza" [] 1010
				"Mexico City" [] 1111
				"Bangkok" [] 1212
			]
			
			
			
			;-        columns:
			; how many columns in item data?
			;
			; for now this is hard-set to 2, but in future versions, we will expand and allow several label columns.
			;columns: 2
			
			
			;-        leading:
			; vertical spacing between items.
			leading: 8
			
			
			;-        font:
			font: theme-menu-item-font
			
			;-        min-width:
			; minimum width of drop-down.
			;
			; carefull cause dimension & min-width is are indirect observers (don't link this to them)
			min-width: 150x0
			
			
			;-        picked-item:
			; when something on the drop list, is actually picked (selected), we insert the value here.
			;
			; note this is NOT a copy, so don't change it.  copy it if you really need to edit the string.
			;
			; setting picked-item manually doesn't cause ANY reaction internally... nothing is linked to it.
			picked-item: none
			
		]

		
		;-    Material[]
		material: make material [
			;-        fill-weight:
			fill-weight: 1x1
			

			;-        item-count:
			; returns the number of items in droplist (length? items / columns).
			item-count: none
			
			;-        current-item:
			; if an item is under mouse, highlight it
			current-item: none
			
			
			;-        primitive:
			; the drop-list is special in that its primitive actually drives some of the basic
			; dimension property.
			;
			; for this reason, we pre-build the primitive to draw and store a few
			; values which it calculated here.
			;
			; other plugs will then link to one or more primitive values.
			;
			primitive: none
			
			
			;-        labels-analysis:
			labels-analysis: none
			
			
			;-        labels-dimension:
			labels-dimension: none
			
		]
		
		
		;-    actions:
		; user functions to trigger on events.
		actions: context [
			item-picked: func [event][
				;print "droplist action!"
				;print event/picked
				;probe event/chosen
			]
		]
		
		
		;-    controled-by:
		; to what control is this droplist associated.
		;
		; the marble usig a drop list will put a reference to itself here
		controled-by: none
		
		
				
		;-    valve[ ]
		valve: make valve [
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'droplist  
			
			
			;-        drop-primitive[]
			;
			; the primitive is an object defined as:
			;
			; context [
			;     draw-block: [...]
			;     size: 100x100
			; ]
			;
			; the min-dimension will be linked to size via a !select plug
			; 
			drop-primitive: make !plug [
				valve: make valve [
					;-----------------
					;-            process()
					;-----------------
					process: func [
						plug data
						/local blk s item items leading cols font current size line-height hi-box min-width off
					][
						vin [{drop-primitive/process()}]
						; we re-use context
						
						plug/liquid: any [
							plug/liquid 
							context [draw-block: copy [] size: 100x100]
						]

						; make sure interface conforms
						if all [
							;6 >= length? data
							block? items: pick data 1
							;integer? cols: pick data 2
							object? font: pick data 2
							integer? leading: pick data 3
							any [
								string? current: pick data 4
								none? current
							]
							pair? pos: off: pick data 5
						][
							cols: bulk-columns items
							
							; skip bulk header
							items: next items
							
							
							
							;	optional arguments
							min-width: 1x0 * any [pick data 6 0]
							
							line-height: font/size + leading * 0x1
							
							; processed values
							items: extract items cols
							size: min-width
							
							
							; create list box text
							blk: compose [
								fill-pen (black)
								font (font)
							]
							hi-box: none
							foreach item items [
								if same? item current [
									hi-box: pos 
								]
								
								append blk compose [
									text (item) (pos + 4x0 + (leading / 2 * 0x1 - 2)) vectorial
								]
								pos: pos + line-height
								size: max size (1x0 * label-dimension item font)
								size: max size (0x1 * pos)
							]
							
							size: size + 4x2 - (off * 0x1)
							
							; finish highlight, now that we know the actual size of primitive. 
							if hi-box [
								hi-box: compose [(prim-glass hi-box - 2x2  (hi-box + line-height + (1x0 * size) - 2x0) theme-glass-color theme-glass-transparency)]
							]
							blk: append blk hi-box
							plug/liquid/size: size
							plug/liquid/draw-block: blk
						]
						vout
					]
					
					
				]
			]
			

			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				pos: none
				
				
				valve: make valve [
					
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						focused? !bool 
						hover? !bool 
						selected? !bool
						
						primitive !any
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
						position dimension focused? primitive
						[
							
							; labels
							pen none
							fill-pen black
							line-width 0.5
;							
							
							line-width 0
							pen none
							fill-pen blue
							(
								data/primitive=/draw-block
							)
							
							; for debugging
							;pen 0.0.0.200
							;fill-pen none
							;box (data/position=)  (data/position= + data/dimension= - 1x1)
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
			; returns index of item to highlight.
			;-----------------
			item-from-coordinates: func [
				droplist [object!]
				offset [pair!]
				/local i picked font
			][
				vin [{item-from-coordinates()}]
				font: content* droplist/aspects/font
				; 2x4 is a hard-coded origin where drawing starts
				picked: offset/y ;second coordinates - 2x4 - content* droplist/material/position
				picked: (to-integer (picked / (font/size + content* droplist/aspects/leading)))
				picked: picked + 1 ;+ 2
				vout
				
				picked
			]
			
			
			
			
			
			
			
			;-----------------
			;-        find-item()
			;
			; return the droplist AT the position of supplied item
			;
			; note: when supplying a string it must be the EXACT same string, cause a single list
			;       might have several items with the same label
			;-----------------
			find-item: func [
				droplist [object!]
				item [string! integer!]
				/local items cols
			][
				vin [{find-item()}]
				items: content* droplist/aspects/items
				cols: bulk-columns items
				
				; skip bulk header
				items: next items
				
				;cols: content* droplist/aspects/columns
				bulk-columns items
				unless string? item [
					item: pick items (item - 1 * cols + 1)
				]

				vout				
				; we ignore invalid pick values
				if string? item [
					if item: find-same items item [
						item
					]
				]
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
				droplist [object!]
				item [string! integer!]
				/local items columns label-column row
			][
				vin [{glass/!} uppercase to-string droplist/valve/style-name {[} droplist/sid {]/find-item()}]
				items: content* droplist/aspects/items
				
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
			
			
			;-----------------
			;-        choose-item()
			;
			; set the current-item.
			;
			;-----------------
			choose-item: func [
				droplist [object!]
				item [string! none!] "none clears the chosen list"
			][
				vin [{choose-item()}]
				if not same? item content* droplist/material/current-item [
					fill* droplist/material/current-item item
				]
				vout
			]
			
			
			
			
			;-----------------
			;-        droplist-handler()
			;
			; this handler is used for testing purposes only. it is shared amongst all marbles, so its 
			; a good and memory efficient handler.
			;-----------------
			droplist-handler: func [
				event [object!]
				/local list picked i l
			][
				vin [{HANDLE LIST EVENTS}]
				vprint event/action
				droplist: event/marble
				
				switch/default event/action [
					start-hover [
						fill* droplist/aspects/hover? true
					]
					
					
					hover [
						vprint "RESOLVING CHOSEN ITEM"
						if picked: item-from-coordinates droplist event/offset [
							if picked: find-item droplist picked [
								picked: first picked
							]
						]

						choose-item droplist picked
					]

					
					end-hover [
						fill* droplist/aspects/hover? false
						
						choose-item droplist none
					]
					

					select [
						;vprint "RESOLVING CHOSEN ITEM"
						if picked: item-from-coordinates droplist event/offset [
						;v?? picked
						
							if picked: find-row droplist picked [
								;probe content* droplist/aspects/chosen
								
								event-lib/queue-event make event compose/only [
									action: 'pick-item
									picked: (first picked)
									; we now return the whole row of droplist, since it may contain user data beyond
									; what the droplist requires.
									picked-data: (picked)
								]
								event-lib/queue-event compose [viewport: event/viewport action: 'remove-overlay]
							]
						]
					]




					pick-item [
						; you could generate this event manually if you wish to simulate
						; a drop-list selection, usefull for user-specified shortcuts
						fill* droplist/aspects/picked-item event/picked
					]
										
					; successfull click
					release [
						fill* droplist/aspects/selected? false
					]
					
					; canceled mouse release event
					drop no-drop [
						fill* droplist/aspects/selected? false
					]
					
					swipe [
						fill* droplist/aspects/hover? true
					]
				
					drop? [
						fill* droplist/aspects/hover? false
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
				droplist
			][
				vin [{materialize()}]
				
				droplist/material/item-count: liquify* epoxy/!bulk-row-count
				droplist/material/primitive: liquify* drop-primitive
				droplist/material/current-item: liquify* !plug
				
				droplist/material/labels-analysis: liquify* epoxy/!bulk-label-analyser
				droplist/material/labels-dimension: liquify* epoxy/!bulk-label-dimension
				droplist/material/min-dimension: liquify* epoxy/!pair-max
				vout
			]
			

			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				droplist
				/local mtrl aspects
			][
				vin [{fasten()}]
				mtrl: droplist/material
				aspects: droplist/aspects
				
				; setup item count
				link* mtrl/item-count aspects/items
				;link* mtrl/item-count aspects/columns
				
				; build primitive automatically when its states change
				link* mtrl/primitive aspects/items
				;link* mtrl/primitive aspects/columns
				link* mtrl/primitive aspects/font
				link* mtrl/primitive aspects/leading
				link* mtrl/primitive mtrl/current-item
				link* mtrl/primitive mtrl/position
				link* mtrl/primitive aspects/min-width
				

				; pre-process label data
				link* mtrl/labels-analysis aspects/items
				link* mtrl/labels-analysis aspects/font
				link* mtrl/labels-analysis aspects/leading
				link* mtrl/labels-analysis mtrl/position
				
				; calculate min-size based on label data measurements.
				link* mtrl/labels-dimension mtrl/labels-analysis
				
				link*/reset mtrl/min-dimension mtrl/labels-dimension
				link* mtrl/min-dimension aspects/min-width
				
				vout
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
				droplist
			][
				vin [{glass/!} uppercase to-string droplist/valve/style-name {[} droplist/sid {]/stylize()}]
				
				; just a quick stream handler for our droplist
				event-lib/handle-stream/within 'droplist-handler :droplist-handler droplist
				
				
				vout
			]
		]
	]
]
