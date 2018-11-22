REBOL [
	; -- Core Header attributes --
	title: "Glass scrolled list"
	file: %group-scrolled-list.r
	version: 1.0.1
	date: 2014-6-4
	author: "Maxim Olivier-Adlhoch"
	purpose: "List & scroller group."
	web: http://www.revault.org/modules/group-scrolled-list.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'group-scrolled-list
	slim-version: 1.2.2
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/group-scrolled-list.r

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
			-Added On-Click facet to scrolled lister layout dialect.
	}
	;-  \ history

	;-  / documentation
	documentation: {
		Combines a simple list with a vertical scroller.
		
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
		new-bulk-list
	]
	epoxy-lib: slim/open/expose 'epoxy none [!box-intersection]
	group-lib: slim/open 'group none
	
	slim/open/expose 'bulk none [
		is-bulk? symmetric-bulks? get-bulk-property   
		set-bulk-property set-bulk-properties  search-bulk-column filter-bulk 
		get-bulk-row bulk-columns bulk-rows copy-bulk sort-bulk insert-bulk-records add-bulk-records 
		make-bulk clear-bulk 
	]
	


	
	
	;--------------------------------------------------------
	;-   
	;- !SCROLLED-LIST[ ]
	!scrolled-list: make group-lib/!group [
	
		;-    aspects[ ]
		aspects: make aspects [
			;-        items:
			; this uses the newer convention used in choice & droplist.
			; is a direct reference to the list's aspects/list plug.
			items: none
			
			;-        label:
			label: none
			
			;-        filter:
			filter: none
			
		]
		
		
		;-    material[ ]
		material: make material [
			border-size: 0x0

			;-        filtered-items:
			; this is provided as utility since you might want to use the filtered list elsewhere.
			;
			; you may only LINK TO since its allocated and linked internally by the group.
			filtered-items: none
			
			;-        user-min-dimension:
			user-min-dimension: none
			
		]


		;-    list-marble:
		list-marble: none
		
		;-    scroller-marble:
		scroller-marble: none
		
		;-    field-marble:
		field-marble: none
		
		;-    label-marble:
		label-marble: none
		
		;-    options-pane:
		options-pane: none
		
		;-    filter-pane:
		filter-pane: none
		
		;-    stiffness:
		stiffness: none
		
		
		
		;-    content-specification:
		; this stores the spec block we execute on setup.
		;
		; it is handled normally by a row frame.
		;
		; note that the dialect for the group itself, is completely redefined for each group.
		;
		; remember that the group itself is a frame, so you can set its looks, and layout mode normally.
		content-specification: [
			label-marble: label "LABEL"
			row tight [
				list-marble: list
				column tight [
					options-pane: column tight []
					scroller-marble: scroller stretch 0x1 with [fill* material/orientation 'vertical]
				]
			]
			filter-pane: row tight [
				field-marble: field ""
				thin-button stiff 20x25 "*" [
					fill* field-marble/aspects/label copy "" 
					gl/unfocus field-marble
				]
			]
		]
		
		
		spacing-on-collect: 0x0
		
		;-    layout-method:
		layout-method: 'column
		
		
		;-    valve []
		valve: make valve [

			;-        style-name:
			style-name: 'scrolled-list
		

			;-        bg-glob-class:
			;-        fg-glob-class:
			; no need for any globs.  just sizing fastening and automated liquification of grouped marbles.
			bg-glob-class: none
			fg-glob-class: none


			;-----------------
			;-        setup-style()
			;-----------------
			setup-style: func [
				group
			][
				vin [{!scrolled-list/setup-style()}]
				group/material/filtered-items: liquify* epoxy-lib/!bulk-filter
				group/material/user-min-dimension: liquify* !plug
				vout
			]
			
			
			
			
	
			;-----------------
			;-        group-specify()
			;-----------------
			group-specify: func [
				group [object!]
				spec [block!]
				stylesheet [block! none!] "required so stylesheet propagates in marbles we create"
				/local data block-count blk
			][
				vin [{!scrolled-list/group-specify()}]
				block-count: 0
				
				;vprobe spec
				;vprint "-----------"
				parse spec [
					any [
						;here: set data skip (probe data ) :here
						
						set data string! (
							vprint "label!!!"
							fill* group/label-marble/aspects/label data
						)
					
						| set data tuple! (
							vprint "frame COLOR!" 
							set-aspect group 'color data
						)
						
						| '.commands set data block! (
							vprint "================================"
							vprobe type? group/options-pane
							blk: bind/copy data group
							sl/layout/within blk group/options-pane
							vprint length? group/options-pane/collection
						)
						
						| copy data ['with block!] (
							;print "SPECIFIED A WITH BLOCK"
							;frame: make frame data/2
							;liquid-lib/reindex-plug frame
							
							do bind/copy data/2 group 
							
							
							;probe marble/actions
							;ask ""
						)
						
						| 'stiff (
							group/stiffness: 'xy
							;fill* group/material/fill-weight 0x0

						)
						| 'stiff-x (
							group/stiffness: 'x
							;fill* group/material/fill-weight 0x0

						)
						| 'stiff-y (
							group/stiffness: 'y
							;fill* group/material/fill-weight 0x0

						)
						
						; remove the label from this group, we don't need it
						| 'no-label (
							;probe "Will remove label"
							;probe type? group/label-marble
							group/valve/gl-discard group group/label-marble
							;group/valve/gl-fasten group
							
							;halt
						)
						
						| 'on-click set data block! (
							;print "A HA!  on-click()"
							if object? get in group/list-marble 'actions [
								group/list-marble/actions: make group/list-marble/actions [
									list-picked: make function! [event] bind/copy data group
								]
							]
						)
						
						| 'on-context-click set data block! (
							;print "CONTEXT CLICK SETUP"
							if object? get in group/list-marble 'actions [
								group/list-marble/actions: make group/list-marble/actions [
									list-context-start: make function! [event] bind/copy data group
								]
							]
						)

						| '.bulk set data [block! | word!] (
							if word? data [ data: get data ]
							unless block? data [to-error "glass/scrolled-list expects bulk data"]
							;fill* marble/aspects/list data
							
							fill* group/aspects/items data
						)
						
						
						; set list data or pick action
						| set data block! (
							
							block-count: block-count + 1
							switch block-count [
								1 [
									; lists support 3 columns, one being label, another options and the last being data.
									; options will change how the item is displayed (bold, strikethru, color, etc).
									fill* group/aspects/items make-bulk/records/properties 3 data [ label-column: 1]
								]
								2 [
									if object? get in group 'actions [
										group/list-marble/actions: make group/list-marble/actions [
											list-picked: make function! [event] bind/copy data group
										]
									]
								]
							]
							
						)
						
						| set data decimal! (
							; DOES NOT SEEM TO WORK CURRENTLY (BUG)
							; !offset-value-bridge doesn't use values at init... needs a bit of investigation
							; may be related to pipe channel handling.
							len: content* group/scroller-marble/aspects/maximum
							value: to-integer data * len
							fill* group/scroller-marble/aspects/value value
							fill* group/list-marble/aspects/list-index value
						)
						
						| set data integer! (
							; DOES NOT SEEM TO WORK CURRENTLY (BUG)
							; !offset-value-bridge doesn't use values at init... needs a bit of investigation
							; may be related to pipe channel handling.
							fill* group/scroller-marble/aspects/value data
						)
						
						| set data pair! (
							fill* group/material/user-min-dimension data
						)
						
						| skip 
					]
				]
				vprint "-----------"
				;----
				; if there aren't any items given at this point, create an empty one... 
				; this allows us to simply append to the system later.
				unless block? content* group/aspects/items [
					fill* group/aspects/items new-bulk-list
				]
				vout
				group
			]
			
			
			
			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				group
			][
				vin [{!scrolled-list/fasten()}]
				
				;print type? group/field-marble
				;print type? group/scroller-marble
				;print type? group/list-marble
				;print type? group/label-marble
				
				; reference inner marble data in outer-group
				group/aspects/filter: group/field-marble/aspects/label
				if group/label-marble [
					group/aspects/label: group/label-marble/aspects/label
				]
				;group/aspects/items: group/list-marble/aspects/list ; this isn't used directly by list-marble.
				
				; link up the filter so we can use the filtered-list within the list
				link*/reset group/material/filtered-items group/aspects/items
				link* group/material/filtered-items group/aspects/filter
				
				;vprobe content* group/aspects/items
				
				link*/reset group/list-marble/aspects/list group/material/filtered-items
			
				; link-up scroller with list-marble
				link*/reset group/scroller-marble/aspects/visible group/list-marble/material/visible-items
				fill* group/scroller-marble/aspects/minimum 1
				link*/reset group/scroller-marble/aspects/maximum group/list-marble/material/row-count
				
				; this is a more complex link since the scroller contains a bridge, we must connect using a channel.
				attach*/to group/list-marble/aspects/list-index group/scroller-marble/aspects/value 'value
			
				switch group/stiffness [
					xy [
						fill* group/material/fill-weight 0x0
						link*/reset group/material/min-dimension group/material/user-min-dimension
					]
					x [
						fill* group/material/fill-weight 0x1
						link*/reset group/material/min-dimension group/material/user-min-dimension
					]
					y [
						fill* group/material/fill-weight 1x0
						link*/reset group/material/min-dimension group/material/user-min-dimension
					]
				]
				vout
			]
		]
	]
]
