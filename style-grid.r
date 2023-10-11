REBOL [
	; -- Core Header attributes --
	title: "Glass grid style marble"
	file: %style-grid.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {Allows single and multi-selection of items within a provided bulk, presented within a single grid of text.}
	web: http://www.revault.org/modules/style-grid.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-grid
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-grid.r

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
		The dump a bulk and look at it in a grid.
		
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
		attach*: attach
		unlink*: unlink
		dirty*: dirty
		processor
	]

	slim/open/expose 'glue none [ !empty? ]

	
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

;	probe face

	base-face: make face [edge: none]





	
	;--------------------------
	;-         border!:
	;
	; used like an edge.  but borders overlap.
	;--------------------------
	border!: context [
		size: 1x1
		color: gray
	;	inside?: false ; do not color interior lines... only supported in header.
	]
	
	




	;--------------------------
	;-         !grid-rasterizer:
	;
	; note, first item in grid may be a special row SPEC used to change the look and feel of that row.
	; look for the row-gfx? spec in the bulk header.
	;--------------------------
	!grid-rasterizer: processor/with/valve 'grid-rasterizer [
		vin [ "grid-rasterizer(" plug/sid ")"]
		
		col-spec: pick data 1
		bulk: pick data 2
		dimension: pick data 3
		origin: pick data 4  ; pair
		cell-font: pick data 5
		hdr-font:  pick data 6
		leading: pick data 7
		chosen: pick data 8
		hdr-clr: pick data 9 ;white * .95 
		cell-clr: pick data 10 ;white 
		grid-brd:  any [pick data 11 make border! [size: 0x0]]
		hdr-brd:   any [pick data 12 make border! [size: 0x0 color: hdr-clr ]]
		cell-brd:  any [pick data 13 make border! [size: 0x0]]


		;probe bulk

		;---------------------------------
		; analyse the bulk header for its specification:
		data-colums:  select bulk/1 first [columns:]
		has-row-gfx?: select bulk/1 first [has-row-gfx?:] ; OPTIONAL! when true, we treat the first column as gfx spec for each row.
;		border: any [
;			select bulk/1 first [border:]
;			border: context [
;				width: 0x0
;				color: gray
;			]
;		]

;		v?? data-colums
;		v?? has-row-gfx?
;		v?? border
;		?? col-spec
;		?? bulk
;		?? dimension
;		?? origin
;		;?? font
;		?? leading
		
		
		;---------------------------------
		; calculate cell and row values
		display-columns: length? col-spec
		
		line-height: cell-font/size + leading + cell-font/offset/y
		cell-height: line-height - cell-brd/size/y
		
		first-row: 1 + to-integer ( origin/y /  line-height)
		
		
		total-rows: to-integer (( length? next bulk) / data-colums)
		
		visible-rows: 1 + to-integer (dimension/y / line-height)
		;v?? visible-rows
		
		visible-rows: min visible-rows (total-rows - first-row + 1)
		
;		v?? line-height
;		v?? cell-height
;		v?? first-row
;		v?? total-rows
;		v?? visible-rows
;		v?? display-columns
;		v?? data-colums


		face: plug/rface 
		face/color: white

		face/size: dimension
		face/edge: none
		
		
		clear face/pane
		 
		hdr-face: make base-face [
			font: hdr-font
			color: hdr-clr
			edge: none
			size: 100x0 + (0x1 * ( cell-height))
			;para: make face/para [wrap?: false]	
		]
		
		col-face: make hdr-face [
			font: cell-font
			color: cell-clr 
		]
		
		
		either has-row-gfx? [
			column: 1
		][
			; skip first column, which is used for gfx 
			column: 2
		]
		
		
		
		
		if grid-brd [
			append face/pane gbf: make base-face [
				offset: 0x0
				color: grid-brd/color
			]
		]
		hbf: cbf: none
		if hdr-brd [
			append face/pane hbf: make base-face [
				offset: 0x0 ;any [all [gbf grid-brd/size] 0x0]
				color: hdr-brd/color
			]
		]
		if cell-brd [
			append face/pane cbf: make base-face [
				offset: any [
					all [gbf grid-brd/size] 
					all [hbf hdr-brd/size] 
					0x0
				]
				color: cell-brd/color
			]
		]
		
		;---------------------------------
		; iterate through columns and render each one.
		;---
		off: 0x0 
		off/x: off/x - origin/x - cell-brd/size/x ; we need to remove the cell border for first column since we add it at each column after
		; calculate the pixel offset related to origin.
		poff: modulo origin/y line-height
		
		hfaces: clear []

		foreach spec col-spec [
			column: column + 1
			spec: context spec
			off/y: grid-brd/size/y 
			off/x: off/x + cell-brd/size/y
			append face/pane cf: hf: make hdr-face [
				text: spec/name 
				size/x: spec/width
				offset: off 
			]
			
			;----------------------------
			; remember which faces are the headers 
			;----------------------------
			append hfaces cf
			off/y: cf/offset/y + cf/size/y + cell-brd/size/y 
			row: 0
			if hbf [
				;-----
				; set header border 
				hbf/size/y: cf/size/y
			]
			
			;v?? COLUMN

			;----
			; skip to current data column
			cell: at bulk 1 + column
			
			;----
			; skip to first row
			cell: skip cell ((first-row - 1) * data-colums)
			
			if has-row-gfx? [
				gfx-specs: at bulk 2
				gfx-specs:  skip gfx-specs ((first-row - 1) * data-colums)
				;?? gfx-spec
			]
			
			;v?? cell
			off/y: off/y - poff
			if visible-rows > 0 [
				;----------------------------
				; render visible cells for this column
				;----------------------------
				until [
					row: row + 1

					append face/pane cf: make col-face [
						offset: off
						size/x: spec/width
						text: form pick cell 1 
						text-align: 'left
					]
					if has-row-gfx? [
						gfx-spec: pick gfx-specs 1
					
						if block? gfx-spec [
							if i: find gfx-spec tuple! [
								cf/color: first i
							]
						]
						gfx-specs: skip gfx-specs data-colums
					]
					;?? col-face
					if find chosen (row + first-row - 1) [
						cf/color: theme-select-color
					]
					
					cell: skip cell data-colums
					off/y: off/y + line-height
					
					any [
						row >= visible-rows
						off/y > dimension/y
					]
				]
			
			]
			; stop generating columns, we are past display, 
			if (cf/offset/x + cf/size/x) > dimension/x [
				break
			]
			
			off/x: off/x + spec/width cell-brd/size/x
		]
		
		if gbf [
			gbf/size: cf/size + cf/offset + (cell-brd/size)
			gbf/size/x: cf/size/x + cf/offset/x + (grid-brd/size/x)
		]
		
		if hbf [
			;-----
			; set header border 
			hbf/size/x: cf/size/x + cf/offset/x
			hbf/size/y: hbf/size/y + hdr-brd/size/y
			either hdr-brd/size/x = 0 [
				hbf/offset: hbf/offset + grid-brd/size 
				hbf/size/x: hbf/size/x - grid-brd/size/x 
			][
				hbf/size: hbf/size +  hdr-brd/size ;+  hdr-brd/size 
			]
		]
		
		if cbf [
			cbf/offset: 0x0
			cbf/offset/y: hf/size/y + hf/offset/y 
			
			cbf/size: cf/size + cf/offset
			cbf/size/y: cbf/size/y - hf/size/y 
			;cbf/size/x: cf/size/x + cf/offset/x - 1
			
			if gbf [
				cbf/offset/x: cbf/offset/x + grid-brd/size/x
				cbf/size: cbf/size - grid-brd/size - grid-brd/size
			]
			if hbf [
				cbf/offset/y: cbf/offset/y + hdr-brd/size/y
				;cbf/size/y: cbf/size/y - hdr-brd/size/y - hdr-brd/size/y
			]
		]

		;----------------------------
		; put header faces back over all faces.
		;----------------------------
		foreach face  hfaces [
			remove find plug/rface/pane face
			append plug/rface/pane face
		]


		; render grid
		plug/liquid: to-image plug/rface
		

		vout
		
	][
		rface: none ;make face [feel: none  ]
	][
		;--------------------------
		;-             setup()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; to do:    
		;
		; tests:    
		;--------------------------
		setup: funcl [
			plug
		][
			vin "setup()"
			vprint "SETTING UP RASTERIZER"
			;ask ".."
			plug/rface: make base-face [ 
				feel: none  
				pane: copy []  
				sid: plug/sid 
			]
			vout
		]
	]



	;--------------------------
	;-         !grid-chooser:
	;
	; take the data and return only those in the chosen list.
	;
	; note that we return IN THE ORDER OF SELECTION
	;--------------------------
	!grid-chooser: processor 'grid-chooser [
		vin "!grid-chooser/processor()"
		bulk-data: pick data 1
		choices: pick data 2
		
		
		; get number of columns dynamically, so we can output symmetric bulk
		if is-bulk? bulk-data [
			;vprobe "IS BULK!"
			columns: get-bulk-property bulk-data 'columns
			;v?? columns
		]
		
		either all [
			columns
			block? choices
		][
			;probe "good to go"
			plug/liquid: any [
				all [
					block? plug/liquid
					append/only clear plug/liquid compose [columns: (columns)]
				]
				make-bulk columns
			]
			;v?? choices
			foreach choice choices [
				; don't forget to skip bulk header... (initial "1 +"  below  )
				append plug/liquid copy/part at bulk-data (1 + (((choice - 1) * columns ) + 1 )) columns ; calculate index in terms of 1 indexing.
;				append plug/liquid  bulk-row choice 
			]
		][
			;---
			; return an empty bulk
			;
			; we should eventually set columns to 0, though this may be impractical, since it may cause 
			; divide by 0 errors later on, in code which doesn't expect it.
			;---
			plug/liquid: copy/deep [[columns: 1 ]]
		]
		
		
		;probe plug/liquid 
		
		vout
	]


	
	;--------------------------
	;-         !grid-line-height:
	;
	;
	;--------------------------
	!grid-line-height: processor '!grid-line-height [
		plug/liquid: any [
			all [
				object?  font:		pick data 1
				integer! leading:	pick data 2
				font/size + leading + font/offset/y
			]
			
		]
	]
	
	
	
	;--------------------------
	;-         !visible-rows:
	;
	; calculates how many items
	;--------------------------
	!visible-rows: processor '!visible-rows [
		vin [{!visible-rows/process()}]
		
		; just make sure we have a proper interface
		plug/liquid: either all [
			integer? rows: pick data 1
			integer? line-height: pick data 2
			pair? dimension: pick data 3
		][
			?? dimension
			?? line-height
			min rows to-integer ((dimension/y - 1 ) / line-height ) 
		][
			0
		]
		vout
	]
	
	
	
	
	;--------------------------
	;-         !grid-data-height:
	;
	; calculates the internal theoretical maximal height of the current grid
	;
	; depends on already calculated rows count.
	;
	; if we ever have a special vertically adaptative grid mode, we may need to improve this a lot.
	;--------------------------
	!grid-data-height: processor '!grid-data-height [
		plug/liquid: any [
			all [
				integer? rows: pick data 1
				integer? line-height: pick data 2
				;rows: rows + 1
				rows * line-height
				;integer? header-height: pick data 3 ; for now, header is the same size as rows
			]
			0
		]
	]
	
	
	;--------------------------
	;-         !grid-visible-height:
	;--------------------------
	!grid-visible-height: processor '!grid-visible-height [
		plug/liquid: any [
			all [
				pair?      dimension: pick data 1
				integer? line-height: pick data 2
				max 0 dimension/y - (line-height * 2) ; * 2 because header AND bottom scrollbar
			]
			0
		]
	]
	
	
	;--------------------------
	;-         !grid-header-width:
	;
	; takes a column spec, all borders and calculates the total width of the grid, 
	; including any borders
	;
	; note that columns should be already calculated if they use dynamic widths.
	;--------------------------
	!grid-header-width: processor '!grid-header-width [
		plug/liquid: 100
		
		if block? columns: pick data 1 [
			gbrd: pick data 2 ; grid border
			hbrd: pick data 3 ; header border
			cbrd: pick data 4 ; cell border
			
			bx: 0 ; border x
			
			if gbrd [
				bx: gbrd/size/x
			]
			if hbrd [
				bx: max hbrd/size/x bx
			]
			width: (bx * 2) 
			if cbrd [
				width: width + (cbrd/size/x * ((length? columns) - 1) )
			]
			foreach column columns [
				;probe column
				width: width + select column first [width:]
			]
			
			;?? width
			plug/liquid: width
		]
	]
	
	

	;--------------------------------------------------------
	;-   
	;- !GRID [ ]
	!grid: make marble-lib/!marble [
	
		;-    Aspects[ ]
		aspects: context [
			;        offset:
			offset: -1x-1
			
			;        focused?:
			focused?: false

			;        hover?:
			hover?: false
			
			;        selected?:
			selected?: false
			
			;-        color:
			; color of cell bg
			color: white 
			
			;--------------------------
			;-        scroller-sizes:
			;
			; width of both scrollers in appropriate orientation
			;--------------------------
			scroller-sizes: 15x15
			
			;--------------------------
			;-        header-color:
			;
			; the color of the header row
			;--------------------------
			header-color: white * .95
			
			;--------------------------
			;-        h-origin:
			;
			;
			;--------------------------
			h-origin: 0
			
			;--------------------------
			;-        v-origin:
			;
			;
			;--------------------------
			v-origin: 0
			
			;-        data:
			data: make-bulk/records 3 [ "" [] "" ]
;			grid: [
;				"New Brunswick123456789" 00
;				"New York" 11
;				"Montreal" 22 
;				"L.A." 33
;				"L.A." 37 ; tests similar labels in the grid
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
			
			;--------------------------
			;        columns:
			; how many columns in grid data?
			;
			; analyses the header setup and returns the number of columns
			;columns: none
			
			;--------------------------
			;        grid-width
			;
			; the x dimension of the grid visuals, which may be larger than the current view.
			;
			; analyses the header setup and returns the total pixel width. 
			;grid-width: none
			
			;--------------------------
			;-        column-spec:
			;
			; a block of blocks which contains specs for columns
			;
			; properties are set-word! and their value is property dependant
			;
			; all properties have defaults.
			;
			; each spec defines one column.  
			; 
			; supported properties are:
			;   name: 				string!
			;   width:            	pair!   (only x is used)
			;						integer! direct pixel width
			;						decimal! (a fraction of grid width doesn't not share with 'stretch columns, total may be more than 1.0   )
			;						word!  ->  stretch  all stretch columns share space left.
			;   adjustable?:		logic!   (the end of the column can be manually moved)
			;   color:	        	tuple!        this column has a special color by default.
			;   is-row-count?		a special column type which just enumerates the row ... doesn't count towards grid data columns
			;
			;  future properties.
			;   index:  move this column at another position in display (index in this spec matches the data)
			;--------------------------
			column-spec: [
				[
					name: "column 1"
					width: 100
				]
			]
			
			;-        grid-index:
			; at what item should the display start showing grid items?
			grid-index: 1
			
			;-        chosen:
			;
			; this is the list of chosen items in the grid.
			;
			; a list of integers
			chosen: [  ]
			
			;-        leading:
			; space between lines.
			leading: 6
			
			;-        font:
			font: make face/font [ ;theme-grid-font [ 
				size: 11 
				align: 'left 
			]
			
			;--------------------------
			;-        header-font:
			header-font: make theme-grid-font [ 
				align: 'left 
				size: 12
			]
			
			;--------------------------
			;-        grid-border:
			grid-border: none ; make border! [color: blue]
			
			;--------------------------
			;-        header-border:
			header-border: none ; make border! [color: green]
			
			;--------------------------
			;-        cell-border:
			cell-border: none ;make border! [color: white * .98]
		]

		
		;-    Material[]
		material: make material [
			;--------------------------
			;-        origin:
			;
			; where is the origin of the visible grid
			;
			; this is just a combination of v-origin and h-origin
			;--------------------------
			origin: 0x0
			
			;--------------------------
			;-        fill-weight:
			; we benefit from extra space.
			;--------------------------
			fill-weight: 1x1

			;--------------------------
			;-        calculated-column-spec:
			;
			; takes the user column spec and calculates any variables it may contain
			; based on the grid's current material and aspects...
			;
			; currently is a stub, anything linking to the column spec, must connect to this one.
			;--------------------------
			calculated-column-spec: none

			;--------------------------
			;-        visible-rows:
			;
			; returns how many rows  CAN be shown in the grid, not how many are currently visible.
			;
			; this is based on the grid size, grid/valve/grid-font/size,  and dimension, but doesn't react to grid-index.
			;
			; if there are fewer rows than can be seen, visible-rows will shrink to it.
			; 
			;--------------------------
			visible-rows: none
			
			;--------------------------
			;-        visible-height:
			;
			; part of the grid area which is used to display grid data (excludes header)
			;--------------------------
			visible-height: none
			
			;--------------------------
			;-        visible-width:
			;
			; part of the grid area which is used to display grid data (excludes header)
			;--------------------------
			visible-width: none
			
			;--------------------------
			;-        v-data-dimension:
			;
			; what is the dimension of the data being shown within the grid?
			;--------------------------
			v-data-dimension: none
			
			;--------------------------
			;-        h-data-dimension:
			;
			; what is the dimension of the data being shown within the grid?
			;--------------------------
			h-data-dimension: none
			
			;--------------------------
			;-        row-count:
			; returns the number of rows in grid.
			;--------------------------
			row-count: none
			
			;--------------------------
			;-        chosen-rows:
			;
			; a version of input grid data with only the chosen in it.
			;
			; it can be used directly as the source of another grid !
			;--------------------------
			chosen-rows: none
			
			;--------------------------
			;
			;-        chosen?:
			;
			; when any selection is active, this turns true.
			;
			; should be used to toggle other plugs based on selection.
			;--------------------------
			chosen?: none
			
			;--------------------------
			;-        raster:
			;
			; this renders the grid for us, generating an image we can use directly.
			;--------------------------
			raster: none
			
			;--------------------------
			;-        line-height:
			;
			; automatically calculate the line-height no matter what happens.
			;--------------------------
			line-height: none
		]
		
		
		;--------------------------
		;-    multi-choose?:
		;--------------------------
		multi-choose?: true
		
		;--------------------------
		;-    actions:
		;--------------------------
		; nothing by default
		actions: context []
		
		;--------------------------
		;-    last-chosen:
		;
		; stores which item was last chosen.
		;
		; any action which clears the list also clears this
		;--------------------------
		last-chosen: none
		
		;--------------------------
		;-    v-scroller:
		; stores the vertical scroller 
		;--------------------------
		v-scroller: none
		
		;--------------------------
		;-    h-scroller:
		; stores the horizontal scroller
		;--------------------------
		h-scroller: none
		
		;--------------------------
		;-    raster-glob:
		;
		; this is where we will store the run-time grid-view glob
		;--------------------------
		raster-glob: none
		
		
		;-                                                                                                       .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- END-USER GRID METHODS
		;
		;-----------------------------------------------------------------------------------------------------------
		

		;--------------------------
		;-     unselect-all()
		;--------------------------
		; purpose:  clears the chosen aspect and propagates (will cause some materials to update)
		;--------------------------
		unselect-all: funcl [
		][
			vin "Glass/style-grid/unselect-all()"
			blk: content self/aspects/chosen
			clear blk
			last-chosen: none
			dirty* self/aspects/chosen
			vout
		]

		
		
		;-                                                                                                       .
		;-----------------------------------------------------------------------------------------------------------
		;
		;- VALVE []
		;
		;-----------------------------------------------------------------------------------------------------------
		valve: make valve [
		
			type: '!marble
		
			;--------------------------
			;-        style-name:
			; used as a label for debugging and node browsing.
			;--------------------------
			style-name: 'grid  
			
			;--------------------------
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			;--------------------------
			glob-class: none 
			
			;--------------------------
			;-        grid-glob:
			;--------------------------
			grid-glob: make !glob [
				pos: none
				
				marble: none
				
				valve: make valve [
					; internal calculation vars
					p: none
					d: none
					e: none
					h?: none
					grid: none
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
						
						; grid specific
						;grid !block ; bulk with grid data
						;grid-index !integer
					;	chosen !block ; one or more chosen items.
						raster !any
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
							fill-pen (
								to-color gel/glob/marble/sid
							)
							box (data/position=) (data/position= + data/dimension= - 1x1)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color focused? selected? raster ; chosen
						[
							(
								d: data/dimension=
								p: data/position=
								e: d + p - 1x1 
								;grid: data/data=
								rastr: data/raster=
								ggm: gel/glob/marble
								
								;probe data/raster=
								;probe rastr/size
;								lh: content gel/glob/marble/material/line-height
;								;?? lh
;								rc: content gel/glob/marble/material/row-count
;								;?? rc
;								vr: content gel/glob/marble/material/visible-rows
;								;?? vr
;								
								;hdd: content ggm/Material/h-data-dimension
								;v?? hdd
								
								;dim: content ggm/material/visible-width
								;v?? dim

								
;								hsrxy: content gel/glob/marble/h-scroller/material/position
;								;?? hsrxy
								
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
							fill-pen none ;(white * .98)
							;pen red; theme-knob-border-color
							;line-width 1
							
							image (data/raster=) (p)
						
							;box (p + 1x1) (e)  
;							
;							; labels
;							pen none
;							fill-pen black
;							line-width 0.5
;							(
;								prim-list/arrows p + 2x2 d - 5x5 theme-list-font content* gel/glob/marble/aspects/leading list data/list-index= data/chosen= none black
;							)
							
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
			
;			
;			;-----------------
;			;        item-from-coordinates()
;			;
;			; returns the index of item under coordinates
;			;-----------------
;			item-from-coordinates: func [
;				grid [object!]
;				coordinates [pair!]
;				/local i picked
;			][
;				vin [{glass/!} uppercase to-string grid/valve/style-name {[} grid/sid {]/item-from-coordinates()}]
;				i: content* grid/aspects/grid-index
;				
;				v?? i
;				; 2x4 is a hard-coded origin where drawing starts
;				picked: second coordinates - 2x4
;				picked: (to-integer (picked / (theme-list-font/size + content* grid/aspects/leading)))
;				picked: picked + i ;+ 2
;				;v?? picked
;				
;				vout
;				
;				picked
;			]
;			
			
		
			
			
			;-----------------
			;-        grid-HANDLER()
			;
			;-----------------
			grid-handler: funcl [
				event [object!]
				;/local grid picked i l data-col label-col
			][
				vin [{HANDLE GRID EVENTS}]
				vprint event/action
				grid: event/marble
				
				aspct: grid/aspects
				mtrl:  grid/material
				
				;------------------------
				; do we need to know the current row for this event?
				;------------------------
				either find [ SELECT SWIPE HOVER CONTEXT-PRESS ] event/action [
					bulk: 		content aspct/data
					dimension:	content mtrl/dimension
					origin: 	content mtrl/origin
					;cell-font:	content aspct/font
					;leading:	content aspct/leading
					line-height: content mtrl/line-height

					;---------------------------------
					; analyse the bulk header for its specification:
					;---------------------------------
					data-colums:  select bulk/1 first [columns:]
					
					;---------------------------------
					; calculate cell and row values
					origin-yoff: modulo origin/y line-height

					
					;v?? origin-yoff
					;v?? line-height
					;v?? origin
					;origin/y: origin/y - origin-yoff
					;v?? origin
					evt-off: event/offset/y
					
					;v?? evt-off
					
					
					first-row: 1 + to-integer ( origin/y /  line-height)
					total-rows: to-integer (( length? next bulk) / data-colums)
;					visible-rows: 1 + to-integer (dimension/y / line-height)
;					visible-rows: min visible-rows (total-rows - first-row + 1)
					current-row:  -1 + first-row + to-integer  ((event/offset/y + origin-yoff) / line-height)
				
					;v?? first-row
					;v?? current-row
					
				][
					;---
					; just in case
					row: 0
				]
				
				
				
				switch/default event/action [
					;--------------------------------------------------------
					; START-HOVER
					;--------------------------------------------------------
					start-hover [
						fill* grid/aspects/hover? true
						fill* grid/v-scroller/aspects/visible? true
						fill* grid/h-scroller/aspects/visible? true
					]
					
					;--------------------------------------------------------
					; HOVER
					;--------------------------------------------------------
					hover [
						v?? current-row
					]
					
					;--------------------------------------------------------
					; END-HOVER
					;--------------------------------------------------------
					end-hover [
						vprobe words-of event
						fill* grid/aspects/hover? false
						unless any [
							event/to-marble = grid/v-scroller 
							event/to-marble = grid/h-scroller
						][
							fill* grid/v-scroller/aspects/visible? false
							fill* grid/h-scroller/aspects/visible? false
						]
					]
					
					
					;--------------------------------------------------------
					; SWIPE & SELECT
					;--------------------------------------------------------
					 swipe select [
						vprint "CHOOSING AN ITEM"
						either all [
							current-row > 0
							current-row <= total-rows 
						][
							;print "---------------------------"
							;print ["SELECT: " current-row]
							;print "---------------------------"
							blk: content grid/aspects/chosen
							case [
								event/shift? [
;									;---
;									; only select multiple rows if the grid allows it.
;									if grid/multi-choose? [
;										if integer? grid/last-chosen [
;											grid/last-chosen: current-row
;											; loop to add all 
;											
;											copy blk 
;											clear blk
;											unique
;											append unique
;											
;											
;											append blk current-row
;											dirty grid/aspects/chosen
;										]
;									]
								]
								
								event/control? [
									;---
									; only select multiple rows if the grid allows it.
									if grid/multi-choose? [
										either i: find blk current-row [
											if event/action <> 'swipe [
												grid/last-chosen: none
												remove i
											]
										][
											grid/last-chosen: current-row
											append blk current-row
										]
										dirty grid/aspects/chosen
										act?: yes 
									]
								]
								
								'default [
									append clear blk current-row
									grid/last-chosen: current-row
									dirty grid/aspects/chosen
									act?: yes 
								]
							]
						][
							;-----
							; we should deselect all list
							unless event/control? [
								grid/unselect-all
								act?: yes 
							]
						]
						if act? [
							do-action make event [
								selected-row: current-row
							]
						]
					]

										
					;--------------------------------------------------------
					; RELEASE
					;--------------------------------------------------------
					; successfull click
					release [
						fill* grid/aspects/selected? false
					]

					;--------------------------------------------------------
					; CONTEXT-PRESS
					;--------------------------------------------------------
					; right click (contextual menu?)
					CONTEXT-PRESS [
						event: make event [
							selected-row: current-row
							row-data: get-bulk-row bulk current-row
						]
					]
					
					;--------------------------------------------------------
					; DROP
					;--------------------------------------------------------
					; canceled mouse release event
					drop no-drop [
						fill* grid/aspects/selected? false
					]
					
					;--------------------------------------------------------
					; DROP?
					;--------------------------------------------------------
					; is the candidate a valid drop target?
					drop? [
						fill* grid/aspects/hover? false
					]
					
					
					;--------------------------------------------------------
					; SCROLL
					;--------------------------------------------------------
					scroll focused-scroll [
						either event/shift? [
							origin: content event/marble/aspects/h-origin
						][
							origin: content event/marble/aspects/v-origin
						]
						font: get-aspect event/marble 'font
						
						switch event/direction [
							pull [
								origin: origin + (  font/size * 2.11 )
							]
							
							push [
								origin: origin - (  font/size * 2.11 )
							]
						]
						origin: to-integer max origin 0
						
						either event/shift? [
							fill* event/marble/aspects/h-origin origin
						][
							fill* event/marble/aspects/v-origin origin
						]
					]
					
					
					;--------------------------------------------------------
					; focus
					;--------------------------------------------------------
					focus [
;						event/marble/label-backup: copy content* event/marble/aspects/label
;						if pair? event/coordinates [
;							set-cursor-from-coordinates event/marble event/coordinates false
;						]
;						fill* event/marble/aspects/focused? true
					]
					
					;--------------------------------------------------------
					; unfocus
					;--------------------------------------------------------
					unfocus [
;						event/marble/label-backup: none
;						fill* event/marble/aspects/focused? false
					]
					
					;--------------------------------------------------------
					; RAW-KEY
					;--------------------------------------------------------
					RAW-KEY [
						amount: content event/marble/material/line-height
						origin: content event/marble/aspects/h-origin
						switch event/key [
							up [
								origin: origin - amount
							]
							down [
								origin: origin + amount
							]
						]
						origin: to-integer max origin 0
						fill* event/marble/aspects/h-origin origin
						;probe event/key
;						type event
					]
				][
					vprint "IGNORED"
				]
				
				; totally configurable end-user event handling.
				; not all actions are implemented in the actions, but this allows the user to 
				; add his own events AND his own actions and still work within the API.
				if event [
					;print "EVENT"
					;probe words-of event
					do-event event
				]
;				do-event event
				
				vout
				none
			]
			
			
			;-----------------
			;-        materialize()
			; 
			; <TO DO> make a purpose built epoxy plug for visible-rows and instantiate it.
			;-----------------
			materialize: funcl [
				grid
			][
				vin [{glass/!} uppercase to-string grid/valve/style-name {[} grid/sid {]/materialize()}]
				
				mtrl: grid/material
				aspct: grid/aspects
				
				;---------------------------------
				;-          --> Setup
				; setup various grid plugs
				;---------------------------------

				; row manipulation
				mtrl/row-count:	liquify* epoxy/!bulk-row-count
				mtrl/line-height:	liquify* !grid-line-height
				mtrl/visible-rows: liquify* !visible-rows
				
				; selection control
				mtrl/chosen-rows: liquify* !grid-chooser
				mtrl/chosen?: liquify*/link !empty? aspct/chosen

				; rendering primitives
				mtrl/origin:            liquify* epoxy/!to-pair
				mtrl/v-data-dimension:  liquify* !grid-data-height
				mtrl/h-data-dimension:  liquify* !grid-header-width
				mtrl/visible-height:    liquify* !grid-visible-height
				mtrl/visible-width:		liquify* epoxy/!x-from-pair

				mtrl/calculated-column-spec: liquify*/link !plug aspct/column-spec
				

				;---------------------------------
				;-          --> Link
				; link up internal plugs
				;---------------------------------
				link*/reset mtrl/chosen-rows aspct/data 
				link*       mtrl/chosen-rows aspct/chosen

				link mtrl/v-data-dimension mtrl/row-count
				link mtrl/v-data-dimension mtrl/line-height
				
				link mtrl/h-data-dimension  mtrl/calculated-column-spec
				link mtrl/h-data-dimension  aspct/grid-border
				link mtrl/h-data-dimension  aspct/header-border
				link mtrl/h-data-dimension  aspct/cell-border

				link mtrl/visible-height mtrl/dimension
				link mtrl/visible-height mtrl/line-height

				link mtrl/visible-width  mtrl/dimension
				
				link mtrl/line-height aspct/font
				link mtrl/line-height aspct/leading
				
				link mtrl/visible-rows mtrl/row-count
				link mtrl/visible-rows mtrl/line-height
				link mtrl/visible-rows mtrl/dimension
				
				link mtrl/row-count aspct/data


				;-          --> Raster
				mtrl/raster: rst: liquify* !grid-rasterizer
				link rst  mtrl/calculated-column-spec
				link rst  aspct/data
				link rst  mtrl/dimension
				link rst  mtrl/origin
				link rst  aspct/font
				link rst  aspct/header-font
				link rst  aspct/leading
				link rst  aspct/chosen
				link rst  aspct/header-color
				link rst  aspct/color
				link rst  aspct/grid-border
				link rst  aspct/header-border
				link rst  aspct/cell-border

				;-          --> scrollers
				grid/v-scroller: vs: alloc-marble 'scroller []
				grid/h-scroller: hs: alloc-marble 'scroller []
				
				;---
				; mutate scrollers
				vs/material/position/valve:  epoxy/!place-at-edge/valve
				vs/material/dimension/valve: epoxy/!dimension-at-edge/valve
				hs/material/position/valve:  epoxy/!place-at-edge/valve
				hs/material/dimension/valve: epoxy/!dimension-at-edge/valve
				
				;---
				; position scrollbars
				link*/reset grid/v-scroller/material/position reduce [
					mtrl/position
					mtrl/dimension 
					vs/material/orientation
					aspct/scroller-sizes
				]
				link*/reset grid/h-scroller/material/position reduce [
					mtrl/position
					mtrl/dimension 
					hs/material/orientation
					aspct/scroller-sizes
				]
				
				;---
				; dimension scrollbars
				link*/reset vs/material/dimension reduce [
					mtrl/position
					mtrl/dimension 
					vs/material/orientation
					aspct/scroller-sizes
				]
				link*/reset hs/material/dimension reduce [
					mtrl/position
					mtrl/dimension 
					hs/material/orientation
					aspct/scroller-sizes
				]
				
				
				;--------
				; link the glob inputs to the scroller's materials and aspects.
				;
				; this is safe, since materialize is called by setup.
				;--------
				vs/valve/link-glob-input vs
				hs/valve/link-glob-input hs

				;--------
				; we must FASTEN scroller immediately, 
				; cause we need to have the bridges setup BEFORE later phases like fastening.
				;
				; the bridges are only setup in the fasten phase (could change to materialize?)
				;
				; we also need to set the orientation before calling fasten, 
				; otherwise the scroller expects a group style layout frame.
				;--------
				fill vs/material/orientation 'vertical
				fill hs/material/orientation 'horizontal
				vs/valve/fasten vs
				hs/valve/fasten hs
				

				fill vs/aspects/minimum 0
				fill hs/aspects/minimum 0
				
				
				link*/reset vs/aspects/maximum mtrl/v-data-dimension
				link*/reset hs/aspects/maximum mtrl/h-data-dimension
				
				link*/reset vs/aspects/visible mtrl/visible-height
				link*/reset hs/aspects/visible mtrl/visible-width
				
				attach*/to aspct/v-origin vs/aspects/value 'value
				attach*/to aspct/h-origin vs/aspects/value 'value
				
				link mtrl/origin hs/aspects/value
				link mtrl/origin vs/aspects/value
				
				grid/raster-glob: liquify* make grid/valve/grid-glob [ marble: (grid) ]
				grid/valve/link-glob-input/using grid grid/raster-glob
				
				vout
			]
			

			;-----------------
			;-        fasten()
			;-----------------
			fasten: func [
				grid
			][
				vin ["" uppercase to-string grid/valve/style-name {[} grid/sid {]/fasten()}]
				
				;-          --> glob!
				grid/glob/valve/link grid/glob grid/raster-glob 
				grid/glob/valve/link grid/glob grid/v-scroller/glob
				grid/glob/valve/link grid/glob grid/h-scroller/glob
				
				;---
				; this is required, for the event engine to resolve marble relative offsets
				;
				; hack!! we setup the frame here, cause earlier events may use frame to setup scroller!
				; DO NOT USE UNFRAME!!
				grid/v-scroller/frame: grid
				grid/h-scroller/frame: grid
				
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
				/local data pair-count tuple-count block-count
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
						| 'stiff (
							fill* marble/material/fill-weight 0x0
						)
						| 'stretch set data pair! (
							fill* marble/material/fill-weight data
						)
						| '.bulk set data block! (
							fill* marble/aspects/data data
						)
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
						| set data string! (
							fill* marble/aspects/label data
						)
						| set data block! (
							block-count: block-count + 1
;							switch block-count [
;								1 [
;									if object? get in marble 'actions [
;										marble/actions: make marble/actions [grid-picked: make function! [event] bind/copy data marble]
;									]
;								]
;								2 [
;									; grids support 3 or more columns, one being label, another options and the last being data.
;									; options will change how the item is displayed (bold, strikethru, color, etc).
;									fill* marble/aspects/data make-bulk/records 3 data
;								]
;							]
							switch block-count [
								1 [
									marble/actions: make marble/actions [action: make function! [event] bind/copy data marble]
								]
								
								2 [
									marble/actions: make marble/actions [alt-action: make function! [event] bind/copy data marble]
								]
							]
						)
						| skip 
					]
				]
				
				
				;----
				; if there aren't any items given at this point, create an empty one... 
				; this allows us to simply append to the system later.
				unless block? content* marble/aspects/data [
					
					fill* marble/aspects/data new-bulk-list
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
				grid
			][
				vin [{glass/!} uppercase to-string grid/valve/style-name {[} grid/sid {]/stylize()}]
				
				
				; just a quick stream handler for our grid
				event-lib/handle-stream/within 'grid-handler :grid-handler grid
				
				
				vout
			]
		]
	]
]
