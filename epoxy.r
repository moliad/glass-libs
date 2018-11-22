REBOL [
	; -- Core Header attributes --
	title: "Glass epoxy, core liquid plugs"
	file: %epoxy.r
	version: 1.0.0
	date: 2013-9-18
	author: "Maxim Olivier-Adlhoch"
	purpose: {Reusable liquid plugs for use in GLASS.  Some of these plugs may eventually find their way in liquid's glue module and be removed frome here.}
	web: http://www.revault.org/modules/epoxy.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'epoxy
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/epoxy.r

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
		This is a collection of reusable liquid !plugs which handle many low-level things 
		within GLASS.
		
		Some of these might not be used by GLASS directly, but are provided since they are useful
		for integrating your app into GLASS.
		
		Also note that, for now, this collection is volatile, and is subject to major changes, 
		so don't count on these existing de-facto in future releases.
	
		Also look at the Glue library for more core plugs.
	}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'epoxy
;
;--------------------------------------

slim/register [
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		dirty?
		liquify*: liquify 
		content*: content 
		fill*: fill 
		link*: link
		unlink*: unlink
		dirty*: dirty
		detach*: detach
		processor
		process*: --process
	]
	glob-lib: slim/open/expose 'glob none [!glob]
	sillica-lib: slim/open 'sillica none
	slim/open/expose 'utils-series  none [ text-to-lines ]
	slim/open/expose 'bulk none [
		is-bulk? symmetric-bulks? get-bulk-property   
		set-bulk-property set-bulk-properties  search-bulk-column filter-bulk 
		get-bulk-row bulk-columns bulk-rows copy-bulk sort-bulk insert-bulk-records add-bulk-records 
		make-bulk clear-bulk 
	]
		
	
	;- FUNCTION
	;-----------------
	;-     calculate-expansion()
	;-----------------
	calculate-expansion: func [
		fd  ; frame-dimension
		fms ; frame-min-size
		ftw ; frame-total-weight
		ms  ; min-size
		rw  ; region-weight
		re  ; region-end
		sp  ; total-spacing - removed from frame-dimension & frame-dimension
	][
		vin [{calculate-expansion()}]
		; xtra space in frame, note we don't allow shrinking, 
		; reduce min-size to shrink.
		xs: max 0 fd - fms
		
		; quick verification.
		either any [
			rw = 0
			ftw = 0
		][
			vout
			; default size is min-size
			ms
		][
			; remove spacing from calculations.
			fd: fd - sp
			fms: fms - sp
	
			vout
			ms + (to-integer (( re / ftw ) * xs)) - (to-integer ((( re - rw ) / ftw) * xs))
		]
	]
	
		
	;-----------------
	;-     intersect-region()
	;-----------------
	intersect-region: func [
		frame-start
		frame-end
		marble-start
		marble-end
	][
		;vin [{glass/intersect-region()}]
		
		start: max frame-start marble-start
		end: min frame-end marble-end
		
		if any [
			end/x < start/x
			end/y < start/y
		][
			start: -1x-1
			end: -1x-1
		]
		
		;vout
		
		reduce [start end]
	]
	
	
	
	
	
	
	;----------------------------------------------------------
	;-
	;- NEW LOW-LEVEL GENERIC PLUGS
	
	;-----------------
	;-     !inlet:
	;
	; this is set to become an official liquid node, used where speed and efficiency is a concern and 
	; dynamic plug computation change is not required.
	;
	; it cannot be linked, but it may be piped or used as a container.
	;
	; it is especially usefull as the input of high-performance, highly-controled liquid networks.
	;
	; this can be considered an "edge" in academia graph theory.
	;-----------------
	!inlet: make !plug [
	
	]
	
	
	;--------------------------
	;-     !list-visibility-calculator:
	;
	; 
	;--------------------------
	!list-visibility-calculator: make !plug [
	
		;list-marble: none
	
		valve: make valve [
			type: '!list-visibility-calculator
			
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
					to-integer min ( bulk-rows list)((dimension/y - 6) / (theme-list-font/size + leading))
				][
					0
				]
				;print ["visible-items: " plug/liquid]
				vout
			]
		]
	]
	
	
	
	
	
	
	;-----------------
	;-     !junction:
	;
	; this is set to become an official liquid node, used where speed and efficiency is a concern and 
	; dynamic plug computation change is not required.
	;
	; major differentiation:
	;     -extra fast, optimisized for speed
	;     -it cannot be piped, or used as a container (use !inlet for that)
	;     -filtering is limited to a count of items in subordinates
	;     -no purification
	;     -data block of process() is reused at each call (be carefull).
	;     
	;
	; it is especially usefull as the processing element of high-performance, highly-controled liquid networks.
	;
	; this can be considered a "node" in academia graph theory.
	;-----------------
	!junction: make !plug [
	
	]
	

	;-     !pair-op[]
	!pair-op: make !junction [
		valve: make valve [
			type: '!pair-op
			
			
			; set this to any function you need within your class derivative.
			operation: :add
			
			
			;-         direction:
			direction: 1x1
			
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local item
			][
				;vin [{epoxy/} uppercase to-string plug/valve/type {[}plug/sid{]/process()}]
				;data
				plug/liquid: direction * any [pick data 1 0]
				;print [ "--------" uppercase to-string plug/valve/type "-------->" ]
				;print plug/liquid
				
				;if plug/valve/type = '!pair-max [probe data]
				foreach item next data [
					plug/liquid: operation plug/liquid item * direction
				]
				;vout
			]
			
			
		]
	]
	
	;-     !pair-add:
	!pair-add: make !pair-op [valve: make valve [type: '!pair-add]]
	
	;-     !pair-mult:
	!pair-mult: make !pair-op [valve: make valve [type: '!pair-mult operation: :multiply]]
	
	
	;-     !pair-subtract:
	!pair-subtract: make !pair-op [valve: make valve [type: '!pair-subtract operation: :subtract]]
	
	
	;-     !pair-max:
	!pair-max: make !pair-op [valve: make valve [type: '!pair-max operation: :max]]
	
	
	
	
	
	;-     !fast-add:
	; fast and safe add function.
	!fast-add: make !junction [
		valve: make valve [
			type: '!fast-add
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				vin [{epoxy/!fast-add/process()}]
				;probe data
				plug/liquid: if 1 < length? data [
					add first data second data
				][0]
				vout
			]
			
		]
			
	]
	
	;-     !fast-sub:
	; fast and safe subtract function.
	!fast-sub: make !junction [
		valve: make valve [
			type: '!fast-sub
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				vin [{epoxy/!fast-add/process()}]
				plug/liquid: if 1 < length? data [
					subtract first data second data
				][0]
				vout
			]
			
		]
			
	]
	
	;-     !range-sub:
	; subtract a range from another.
	;
	; the detail is that the range is inclusive, so must be One more  
	; than the 0-based matb subtract
	!range-sub: make !junction [
		valve: make valve [
			type: '!range-sub
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				vin [{epoxy/!fast-add/process()}]
				plug/liquid: either 1 < length? data [
					1 + subtract first data second data
				][0]
				vout
			]
			
		]
			
	]
	
	
	
	;--------------------------
	;-     !scale()
	;--------------------------
	; purpose:  scales a value by a factor
	;
	; inputs:   factor : can be any number type
	;           value:   can be any scalar type
	;
	; returns:  
	;
	; notes:    returns none if inputs are invalid.
	;           plug is none transparent
	;           do not mix the order of inputs.
	;
	; tests:    
	;--------------------------
	!scale: processor '!scale [
		vin "epoxy/!scale()"
		;------
		; use the first input to scale the second
		plug/liquid: all [
			number? factor: pick data 1
			scalar? value: pick data 2
			factor * value
		]
		
		vout
	]
	
	
	
	
	
	
	;-     !to-pair:
	;
	; using one or two inputs, output a pair
	;
	; one input will output in X & Y,  two outputs will use the 
	; first value in X and second in Y.
	;
	; note that if the input(s) have different items (pair, block, tuple, etc)
	; the X will use xdata/1  and  Y will use ydata/2 
	!to-pair: processor 'to-pair [
		vin [{to-pair/process()}]
		
		plug/liquid: if all [
			xdata: pick data 1
			ydata: any [ 
				pick data 2
				xdata
			]
		][
			if find [ tuple! pair! block! ] type?/word xdata [
				xdata: xdata/1
			]
			xdata: 1x0 * any [xdata 0]
			
			if find [ tuple! pair! block! ] type?/word ydata [
				; in case block isn't of length 2, we fallback to length 1
				ydata: any [ydata/2 ydata/1]
			]
			ydata: 0x1 * any [ydata 0]
			
			xdata + ydata
		][
			0x0
		]
			
		
		vout
	]
	
	
	;-     !integers-to-pair: []
	!integers-to-pair: process* '!integers-to-pair [
		x y
	][
		vin "!integers-to-pair()"
		x: any [pick data 1 0]
		y: any [pick data 2 x]
		plug/liquid: (1x0 * x) + (0x1 * y)
		vout
	]
	
	;-     !negated-integers-to-pair: []
	!negated-integers-to-pair: process* '!negated-integers-to-pair [
		x y
	][
		vin "!integers-to-pair()"
		x: any [pick data 1 0]
		y: any [pick data 2 x]
		plug/liquid: (-1x0 * x) + (0x-1 * y)
		vout
	]
	
	
	;-     !merge[]
	;
	; simply returns a all inputs accumulated into one single block.
	; 
	;
	; inputs:
	;    expects to be used linked... doesn't really make sense otherwise
	;
	;    any data can be linked except for unset!
	;    block inputs are merged into a single block, but their block contents aren't.
	;
	;  so:
	;     [[111] [222] 333 [444 555 [666]]]  
	;
	;  becomes:
	;     [111 222 333 444 555 [666]]
	;
	;
	; note that chaining !merge plugs will preserve these un merged blocks in an indefinite
	; number of sub links, because the liquid is a block.
	; 
	; ex using the above:
	;     [ [111 222 333 444 555 [666]]  [111 222 333 444 555 [666]] ]
	;
	; becomes:
	;     [ 111 222 333 444 555 [666]  111 222 333 444 555 [666] ]

	!merge: make !plug [
		valve: make valve [
			type: 'merge
			
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				vin [{process()}]
				; we reuse the same block at each eval (saves series reallocation & GC overhead)
				plug/liquid: clear []
				
				foreach item data [
					append plug/liquid :item
				]
				vout
			]
		]
	]
	
	
	;-----------------
	;-     !x-from-pair:[]
	;-----------------
	!x-from-pair: processor '!x-from-pair [
		;vin [{!x-from-pair()}]
		plug/liquid: first first data
		;vout
	]
	
	
	;-----------------
	;-     !y-from-pair:[]
	;-----------------
	!y-from-pair: processor '!y-from-pair [
		;vin [{!y-from-pair()}]
		plug/liquid: second first data
		;vout
	]
	
	
	
	
	
	
	;-     !chose-items: [p]
	!chose-items: process* '!chose-items [blk chosen][
		plug/liquid: any [
			if all [
				block? blk: pick data 1
				block? chosen: pick data 2
				not empty? chosen
				not empty? blk
			][
				search-bulk-column/all/row/same blk 'label-column chosen
			] 
			; if inputs are invalid, return empty block.
			copy []
		]
	]
	
	
	;-                                                                                                         .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PIPE MASTERS
	;
	;-----------------------------------------------------------------------------------------------------------
	;-     !to-string-pipe-master
	!to-string-pipe-master: make !plug [
		;--------------------------
		;-         all-or-not?:
		;
		; when true, any mold is done with /all option.
		;--------------------------
		all-or-not?: false
		
		
		valve: make valve [
		
			type: '!to-string-pipe
			;--------------------------
			;-         purify()
			;--------------------------
			; purpose:  will always convert data to string (useful for fields)
			;
			; tests:    
			;--------------------------
			purify: funcl [
				plug
			][
				vin "to-string-pipe-master/purify()"
				switch/default type?/word plug/liquid [
					string! [
						; nothing to do.. already a string.
					]
					binary [
						as-string plug/liquid
					]
				][
					either plug/all-or-not? [
						plug/liquid: mold/all plug/liquid
					][
						plug/liquid: mold plug/liquid
					]
				]
				vout
				false
			]
			
		]
	]
	
	;-     !piped-to-string
	!piped-to-string: make !plug [
		valve: make valve [
			type: '!piped-to-string
			pipe-server-class: !to-string-pipe-master
		]
	]
	
	
	;--------------------------
	;-     !purified-type
	;
	;   notes:  -not all type conversion pairs may work, use logically
	;
	;           -also note that some types are value converted to appear logical in GUIs
	;            this IS part of Glass after all.  ex: is file<->string which use rebol<->OS
	;            representations
	;  
	;--------------------------
	!purified-type: make !plug [
		;--------------------------
		;-         dtype
		;
		; the type we must cast to.
		;
		; when an invalid type convertion occurs, the output is default-value
		;
		;-------------------------
		; ATTENTION:  we use datatype! values, not their word! equivalent...
		;             i.e. #[datatype! string!]  not 'string!
		;--------------------------
		dtype: string!
		
		;--------------------------
		;-             default-value:
		;
		; this is used when conversion is impossible.
		;--------------------------
		default-value: ""
		
		;--------------------------
		;-             update-default:
		;
		; when true, the default-value will be updated everytime it is sucessful.
		;
		; we do not support any function values for plug/dtype
		;--------------------------
		update-default: true
		
		valve: make valve [
			type: '!purified-type
						
			;--------------------------
			;-         purify()
			;--------------------------
			; purpose: converts input to type set in plug.
			;--------------------------
			purify: funcl [
				plug
			][
				vin ["purified-type/purify(" plug/dytpe ")" ]
				
				if any-function? plug/dtype [
					to-error "purified-type/purify() function types are not allowed for plug/dtype"
				]
				
				unless (type? plug/liquid ) = ( plug/dtype ) [
					val: plug/liquid
					plug/liquid: none
					attempt [
						switch/default plug/dtype [
							;---
							; TO STRING
							;---
							#[datatype! string!] [
								switch/default type? val [
									;------
									; FROM STRING
									;---
									#[datatype! string!] 
									#[datatype! binary!] [
										plug/liquid: as-string val
									]
									
									;------
									; FROM NONE
									;---
									#[datatype! none!][
										plug/liquid: copy ""
									]
									
									;------
									; FROM FILE!
									;---
									#[datatype! file!][
										plug/liquid: to-local-file clean-path val
									]
									
									
								][
									plug/liquid: mold val
								]
							]
							
							;---
							; TO INTEGER
							;---
							#[datatype! integer!] [
								plug/liquid: to-integer val
							]

							;------
							; TO FILE!
							;---
							#[datatype! file!][
								switch/default type? val [
									;------
									; FROM STRING
									;---
									#[datatype! string!] [
										plug/liquid: to-rebol-file val
									]
								][
									either file? plug/default-value [
										plug/liquid: plug/default-value
									][
										plug/liquid: %./new-file.txt
									]
								]
							]
						][
							plug/liquid: to plug/dtype val
						]
					]
				]

				either (type? plug/liquid ) = ( plug/dtype ) [
					;----------
					; SUCCESS HANDLING
					if plug/update-default [
						plug/default-value: plug/liquid
					]
				][
					;----------
					; ERROR HANDLING
					plug/liquid: plug/default-value
				]
				vout
				false
			]
			
		]
	]
	
	
	;------------------------------
	;-     !piped-to-datatype
	;
	; a plug which creates a !datatyped-pipe-master when piped.
	;
	; this is used when a value needs to be typed whatever its pipe clients supply.
	;------------------------------
	!piped-to-datatype: make !plug [
		valve: make valve [
			type: '!piped-to-datatype
			pipe-server-class: !purified-type
		]
	]
	
	
	
	
	
	
	
	
	
	
	
	
	
	;----------------------------------------------------------
	;-  
	;- BULK HANDING
	
	
	
	;------------------------------
	;-     !bulk-row-count[]
	;------------------------------
	; returns the number of rows in an bulk using a flat block as data and 
	; a column size
	;
	; if the column size isn't linked, the we fallback to 1, useful for lists.
	;
	; note we use a pretty drastic measure, we do not use the bulk functions to save processing.
	;------------------------------
	!bulk-row-count: make !plug [
	
		valve: make valve [
			type: 'row-count
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug 
				data
				/local blk cols
			][
				vin [{!bulk-row-count/process()}]
				
				plug/liquid: any [
					all [
						block? blk: pick data 1
						block? hdr: pick blk 1
						integer? cols: select hdr first [columns:] ; this is how to select using set words!!!
						cols > 0
						((length? blk) - 1) / cols
					]
					
					;---
					; we normalize the value to an integer, if first input isn't a block or not a bulk.
					0
				]
				
				vout
			]
		]
	]
	

	
	;----------------------------------------
	;-     !bulk-filter: [process*]
	;
	; inputs:
	;     bulk [block!]: MUST BE A VALID BULK
	;     filter-label(s) [string! block!]: if its a block, it must only contain strings! furthermore these must be the same string! reference (not mere equivalent strings)
	;
	; optional inputs:
	;     mode [word!]: switches how the filter operates, its 'simple by default
	;					currently supported: 'simple, 'same
	;
	;                   when 'same is used, only the exact same strings will be left in bulk,
	;                   even if other strings match the text itself.
	; output:
	;     a copy of the input bulk with only items from filter
	; be carefull, if the first input isn't a proper bulk, liquid WILL BE NONE
	; 
	;----------------------------------------
	!bulk-filter: process* '!bulk-filter [filter-mode spec][
		vin "!bulk-filter/process()"
		
		spec: pick data 2
		plug/liquid: if all [
			spec
			is-bulk? first data
		][
			filter-mode: any [pick data 3 'simple]
			switch filter-mode [
				simple [
					; !bulk-filter is used to filter chosen block in list style.
					; in this case link a dummy plug with the value 'same to it.
					plug/liquid: filter-bulk/no-copy-same first data filter-mode reduce ['label-column spec]
				]
				same [
					spec: any [
						all [block? spec spec]
						all [string? spec reduce [spec]]
					]
					plug/liquid: filter-bulk first data filter-mode spec
				
				]
			]
		] 
		vout 
	]
	



	
	;-     !bulk-label-analyser[p]
	;
	; analyse all the labels in a datablock column and return a new datablock with results
	; 
	; inputs:
	;    (required)
	;	 	bulk:   block!    bulk bulk
	;		------columns: integer!  number of columns in bulk
	;		font:    object!   a view font to use for label size analysis
	;		leading: integer!  extra space between lines.
	;
	;    (optional)
	;		offset: pair!         add this offset to positions
	;		clip-width: integer!  when  providing length info. clip it to this pixel width.
	;		------column:  integer!  column index to use as the label field (1 by default).
	;
	; output:
	;	 a new bulk with one row of information foreach label
	;
	; format:
	;	 ["label" label-length text-dimension from-position to-position]
	;
	; notes:
	;    -if clip-width is given, length may be less than actual label length
	;    -for performance reasons, the plug's liquid is reused at each process, do not tamper 
	;     with it outside of plug or application corruption may occur.
	;
	!bulk-label-analyser: make !plug [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local bulk columns column font leading offset clip-width
					   blk position line-height size label labels total-size
			][
				vin [{!bulk-label-analyser/process()}]
				; we re-use context
;				vprobe data
				
				either plug/liquid [
					; erase previous bulk data, but keep bulk itself.
					clear-bulk plug/liquid
				][
					; create a new bulk with 5 item records
					plug/liquid: make-bulk 5
				]


				; make sure interface conforms
				if all [
					;------
					; required inputs
					3 <= length? data
					block? bulk: pick data 1
					object? font: pick data 2
					integer? leading: pick data 3
				][
					;------
					;	clean up optional inputs
					position: offset: any [
						all [pair? offset: pick data 4  offset ] 
						0x0
					]
					
					; not yet supported, but will be shortly, when list is updated to use
					; bulk dataset
					clip-width: 1x0 * any [
						all [
							clip-width: pick data 5
							any [pair? clip-width number? clip-width]
							clip-width
						]
						0
					]
					
					columns: get-bulk-property bulk 'columns
					
					; if this bulk has a defined label column use it, otherwise use the first one by default.
					column: any [ get-bulk-property bulk 'label-column 1 ]
					line-height: font/size + leading * 0x1


;					?? bulk
;					v?? columns
;					v?? font
;					v?? leading
;					v?? position
;					v?? clip-width
;					v?? column
;					v?? columns
;					v?? line-height

					;skip bulk header
					bulk: next bulk
					labels: extract at bulk column columns


					;v?? bulk
					
					; calculate total width
					total-size: 0x0
					foreach label labels [
						total-size: max total-size sillica-lib/label-dimension label font
					]
					
;					v?? total-size
					
					foreach label labels [
;						vprint label
						
						size: sillica-lib/label-dimension label font
						
						add-bulk-records plug/liquid reduce [
							label 
							length? label 
							size 
							position
							position + line-height + ( 1x0 * total-size)
						]
						
						position: position + line-height
					]
					
				]
				vout
			]
			
			
		]
	]	


	
	;-     !bulk-label-dimension[p]
	;
	; using data from the bulk-label-analyser, return the dimension of the box
	;
	; inputs :
	;     a bulk returned from bulk-label-analyser
	;
	!bulk-label-dimension: make !plug [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
				/local bulk from to
			][
				vin [{!bulk-label-dimension/process()}]
				
				
				plug/liquid: either all [
					is-bulk? bulk: pick data 1
					pair? from: pick (get-bulk-row bulk 1) 4
					pair? to: last bulk
				][
					to - from
				][
					; at least the output won't crash processes depending on a pair.
					; the -1x-1 value in GLASS has a special meaning which equates to "unspecified".
					-1x-1
				]
				
				vout
			]
			
			
		]
	]
	
	
	
	;------------------------------
	;-     !bulk-lines[p]
	;
	;  this is a node which takes any input and purifies it into a one column bulk with one row per line
	;  it is used in the text editors.
	;  
	;  input:
	;    any plug, but is very effective as a pipe server, since the convertion is done in purify() instead of process()
	;
	;  output:
	;    a bulk or lines, 1 line per row.
	;
	;  notes:
	;	will convert any input to bulk text output, none will become a single empty row. [""]
	;
	;   when plugging in bulk into this node (fill or link) be carefull not to provide invalid data.
	;
	;   if the input is already a bulk, it will output the first column of that bulk.
	;   if the input buld already is a single column, it will output it AS-IS not doing any convertion.
	;
	;   it is valid to edit the content in place and simply call notify on the bulk since this allows
	;   great memory saving.
	;
	;   note that we use only the first value which is linked into the plug.
	!bulk-lines: make !plug [
	
		valve: make valve [
			type: 'bulk-lines
			
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				plug/liquid: pick data 1
			]
			
			;-----------------
			;-         purify()
			;
			; because we do the convertion in purify rather that process,
			; any changes done here will persist and no memory copy will take place
			; unless required.
			;
			; this also allows the plug to be used as a pipe server output filter as-is
			;-----------------
			purify: func [
				plug
				/local blk str
			][
				vin [{!bulk-lines/purify()}]
				
				switch/default type?/word plug/liquid [
					block! [
						; do nothing, we expect data to be a bulk
					]
					string! [
						str: plug/liquid
						; we convert the text to a bulk
						blk: make-bulk 1
						append blk text-to-lines str
						plug/liquid: blk
					]
				][
					; useful universal convertion
					str: mold plug/liquid
					blk: make-bulk 1
								
					append blk parse/all str "^/"

					plug/liquid: blk
				]
				vout
				false
			]
		]
	]

	;------------------------------
	;-     !bulk-join-lines[p]
	;
	; counter part to bulk-lines which takes the bulk and purifies it into a single string of text.
	;------------------------------
	!bulk-join-lines: make !plug [
	
		valve: make valve [
			type: 'bulk-join-lines
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
			][
				plug/liquid: pick data 1
			]
			
			;-----------------
			;-         purify()
			;
			; because we do the convertion in purify rather that process,
			; any changes done here will persist and no memory copy will take place
			; unless required.
			;
			; this also allows the plug to be used as a pipe server output filter as-is
			;-----------------
			purify: func [
				plug
				/local blk str
			][
				vin [{!bulk-join-lines/purify()}]
				
				switch/default type?/word plug/liquid [
					block! [
						str: copy ""
						foreach line next plug/liquid [
							append str join line "^/"
						]
						unless empty? str [
							remove back tail str
						]
						plug/liquid: str
					]
					string! [
						; do nothing, we expect data to be a string
					]
				][
					; useful universal convertion
					str: mold plug/liquid
					plug/liquid: str
				]
				;print "."
				vout
				false
			]
		]
	]
	
	
	;----------------------------------------------
	;-    !bulk-sort[process*]
	;----------------------------------------------
	; takes a bulk and sorts each column according to a default of given column
	;
	;  inputs:
	;    -bulk to sort [bulk!]
	;    -column to sort on (optional)[integer! word!], if not given, we use the bulk's default label column, or first column.
	;
	;  output:
	;    a new bulk which is sorted.
	;
	;  notes:
	;     we SHARE any series or compound data from input bulk, all we do is re-organise it within a new block!
	;----------------------------------------------
	!bulk-sort: process* '!bulk-sort [blk sort-column columns][
		either is-bulk? blk: pick data 1 [
			columns: bulk-columns blk
			; given sort column
			sort-column: pick data 2 
			
			plug/liquid: any [
				all [
					; reuse previous liquid block!
					block? plug/liquid 
					clear plug/liquid
					append plug/liquid blk
				] 
				
				; create new liquid
				copy blk
			]
			bulk-sort/using plug/liquid sort-column
			
		][
			; the input was not a bulk, just output some empty default bulk
			; here we re-use to prevent memory recycling abuse.
			either is-blk? plug/liquid [
				clear-bulk plug/liquid
			][
				plug/liquid: make-bulk 1
			]
		]
	]
	
	

	
	;----------------------------------------------------------
	;-  
	;- GRAPHICS PLUGS

	;------------------------------
	;-     !image-size[]
	;
	;  expects an image input, 
	;
	;  output:
	;    a pair which is the size of the input image
	;
	;  notes:
	;     will revert to a fallback of 0x0 if the input is not an image:
	;
	; when the intersection is empty, a box of [-1x-1 -1x-1] is returned.  in any other case, all rectangle values are positive.
	;------------------------------
	!image-size: make !junction [
	
		mode: 'xy ; can also be 'x or 'y
		
		valve: make valve [
			type: 'image-size
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local img
			][
				plug/liquid: either image? img: pick data 1 [
					switch plug/mode [
						xy [img/size]
						x [img/size * 1x0]
						y [img/size * 0x1]
					]
				][
					0x0
				]
			]
		]
	]


	
	;------------------------------
	;-     !box-intersection[]
	;
	;  expects two, three OR four inputs, the type of the third input determines mode:
	;     setup A)
	;         pos-a   ( pair! )
	;         size-a  ( pair! )
	;         pos-b   ( pair! )
	;         size-b  ( pair! )
	;
	;     setup B)
	;         pos-a           ( pair! )
	;         size-a          ( pair! )
	;         clip-rectangle  ( [ start: pair! end: pair! ] ) -> from parent-frame
	;
	;     setup C)
	;         pos-a           ( pair! )
	;         size-a          ( pair! )
	;
	;  output:
	;     a clip-rectangle block of two pairs which defines a box
	;    [ start end ] = [pair! pair!] = [20x20 100x100] 
	;
	;  notes:
	;     all coordinates are absolute, sizes should be added to positions.
	;
	; when the intersection is empty, a box of [-1x-1 -1x-1] is returned.  in any other case, all rectangle values are positive.
	!box-intersection: make !junction [
		valve: make valve [
			type: 'box-intersection
			
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
			][
				vin [{epoxy/!box-intersection[} plug/sid {]/process()}]
				; default value is an empty clipping rectangle... meaning don't draw anything !!!
				plug/liquid: [-1x-1 -1x-1]
				
				;v?? data
				
				switch length? data [
					;---
					; setup A
					4 [
						plug/liquid: intersect-region data/1 (data/1 + data/2) data/3  (data/3 + data/4)
					]
					
					;---
					; setup B
					3 [
						; make sure we really have all data... (its not an incomplete 4 input setup)
						if block? pick data 3 [
							plug/liquid: intersect-region data/1 (data/1 + data/2)  data/3/1 data/3/2
						]
					]
					
					;---
					; setup C
					2 [
						; note this could be an incomplete setup A or B
						plug/liquid: reduce [data/1 data/1 + data/2]
					]
					
				]
				
				vprint ["liquid: " mold plug/liquid]
				vout
			]
		]
	]
	
	
	
	;-     !pin[]
	;
	; calculate relative positioning using several coordinates and reference points.
	;
	; reference point labels are:
	;    center,  
	;    top, T, bottom, B, right, R, left, L
	;    north, N, south, S, east, E, west, W
	;    top-left, TL, top-right, TR, bottom-left, BL, bottom-right, BR
	;    north-west, NW, north-east, NE, south-west, SW, south-east, SE
	;
	; inputs:
	;     coordinates: [from-point to-point]
	;     from-dimension:
	;     to-position:
	;     to-dimension:
	;
	; optional inputs
	;     from-offset: note, this isn't material/position, (position is what we return)
	;
	; note first input is often used as a filled value, used in linked containers.
	
	!pin: process* 'pin [from-point from-offset from-dimension to-point to-offset to-dimension src-off dest-offset] [
		vin "PIN!/PROCESS()"
		
		plug/liquid: either all [
			block? pick data 1
			word? from-point: pick data/1 1
			word? to-point: pick data/1 2
			
			pair? from-dimension: pick data 2
			pair? to-position: pick data 3
			pair? to-dimension: pick data 4
			pair? from-offset: any [pick data 5 0x0]
		][
			300x300
			;probe length? data
			;?? from-point
			;?? to-point
			;?? from-dimension
			;?? to-position
			;?? to-dimension
			;?? from-offset
		
			;----------
			; the marble we are positioning
			;----------
			src-offset: from-offset + switch/default from-point [
				center [
					to-dimension / 2
				]
				top-left [
					0x0
				]
			][0x0]
			
			;----------
			; The marble we are aligning against
			;----------
			dest-offset: to-position + switch/default to-point [
				center [
					from-dimension / -2
				]
				bottom-left [
					(to-dimension * 0x1)
				]
				top-left [
					0x0
				]
			][0x0]
			
			src-offset + dest-offset
		][
			vprint "!pin/process() error:"
			vprobe data
			0x0
		]
		vout
	]
	
	
	
	
	
	;-----------------
	;-     !label-min-size()
	;
	; this is a commonly-used and very practical plug
	;
	; inputs:
	;    manual-sizing: [pair! none]
	;    label: [string!]
	;
	; optional inputs:
	;    font: [object!] " if not set, use theme-default-font"
	;    padding: [pair!] "adds respective value to either side of orientation"
	;             default-padding is 3x2
	;    
	; output:
	;    a pair which fits both manual-sizing and automatic-sizing.
	;
	; notes:
	;    if ONLY x or y of manual-sizing are = -1 then that orientation
	;    is auto-calculated, based on the other manual sizing orientation
	;
	;    if both are -1 then its the same as specifying none, in which case
	;    the default box is an unlimited text box in both directions, constrained
	;    only by text sizing including manual line-feeds and font properties.
	;
	;    if text is none, we return (max 0x0 manual-sizing)
	;-----------------
	!label-min-size: process* '!label-min-size [
		man-size label font padding
	][
		vin [{!label-min-size/process()}]
		;probe data
		man-size: pick data 1
		either man-size [
			unless string? label: pick data 2 [
				switch type?/word label [
					;none [""]
				]
			]
			font: any [pick data 3 theme-base-font]
			padding: any [pick data 4 3x2]
			
			
			; determine what to resize
			
			plug/liquid: case [
			
				none? label [
				 (max 0x0 any [man-size 0x0])
				]
			
				; totally fixed minimum size
				all [ pair? man-size  man-size/x <> -1  man-size/y <> -1  ][
					man-size
				]
				
				; total auto-sizing
				man-size = -1x-1 [
					sillica-lib/label-dimension label font
				]
				
				man-size/x = -1 [
					;plug/liquid: 1x1 * man-size/y
					sillica-lib/label-dimension/height label font man-size/y
				]
				
				man-size/y = -1 [
					sillica-lib/label-dimension/width label font man-size/x
				]
				true [0x0]
			]
			
			
			;print ["label size " mold label " : " plug/liquid]
			
			
			; add given or default padding
			if plug/liquid <> 0x0 [
				plug/liquid: plug/liquid + padding + padding
			]
			
		][	
			;probe "AUTO SIZE IS MANUALLY SET TO NONE"
			;ask "!!!"
			; when size is none, no sizing occurs, we just use default glass box-size
			; the generic GLASS box size.
			plug/liquid: 30x30
		]
		
		
		vout
	]
	
	
	
	
	
	
	;-     !vertical-accumulate[]
	;
	; optimised plug which adds up pairs in a single direction.
	; accepts integer or pair values
	!vertical-accumulate: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local item dir
			][
				vin [{epoxy/!vertical-accumulate/process()}]
				; the first data segment is the basis, which is increased by any following plugs
				plug/liquid: 1x1 * any [pick data 1 0x0]
				
				; increase size in X
				; add up size in Y
				foreach item next data [
					plug/liquid: max item item * 0x1 + plug/liquid 
				]
				vout
			]
		]
	]
	
	;-     !horizontal-accumulate[]
	;
	; optimised plug which adds up pairs in a single direction.
	; accepts integer or pair values
	!horizontal-accumulate: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local item dir
			][
				vin [{epoxy/!horizontal-accumulate/process()}]
				; the first data segment is the basis, which is increased by any following plugs
				plug/liquid: 1x1 * any [pick data 1 0x0]
				
				; increase size in X
				; add up size in Y
				foreach item next data [
					;plug/liquid: max plug/liquid item * 1x0 + plug/liquid 
					plug/liquid: max item  item * 1x0 + plug/liquid 
				]
				vout
			]
		]
	]
	
	
	
	;-     !vertical-shift[]
	;
	; optimised plug which increases only the Y attribute of first input according to all other connected 
	; inputs
	;
	; accepts any number of integers or pairs linked.
	;
	; cannot be piped.
	!vertical-shift: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local item dir
			][
				vin [{epoxy/!vertical-shift/process()}]
				
				vprobe data
				; the first data segment is the basis, which is increased by any following plugs
				plug/liquid: 1x1 * any [pick data 1 0x0]
				
				; increase size in X
				; add up size in Y
				foreach item next data [
					plug/liquid: max plug/liquid item * 0x1 + plug/liquid 
				]
				vprobe plug/liquid
				vout
			]
		]
	]
	
	;-     !horizontal-shift[]
	;
	; optimised plug which increases only the Y attribute of first input according to all other connected 
	; inputs
	;
	; accepts any number of integers or pairs linked.
	;
	; cannot be piped.
	!horizontal-shift: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug data
				/local item dir
			][
				vin [{epoxy/!horizontal-shift/process()}]
				
				vprobe data
				; the first data segment is the basis, which is increased by any following plugs
				plug/liquid: 1x1 * any [pick data 1 0x0]
				
				; increase size in X
				; add up size in Y
				foreach item next data [
					plug/liquid: max plug/liquid item * 1x0 + plug/liquid 
				]
				vprobe plug/liquid
				vout
			]
		]
	]
	


	;-----------------
	;-        !place-at-edge: []
	;
	; this is a purpose-built positioner for scrollers
	;
	; inputs:
	;    frame-position
	;    frame-dimension
	;    edge
	;    marble-min-size: based on edge, we will use x or y value.
	;-----------------
	!place-at-edge: processor '!place-at-edge [
		;vin [{!place-at-edge/process}]
		
		position: pick data 1
		dimension: pick data 2
		edge: pick data 3
		min-size: 1x1 * pick data 4 ; can be a width
		
	
		
		plug/liquid: switch/default edge [
			; synonym for bottom
			horizontal [
				position + ( dimension - min-size * 0x1) ;- 0x1
			]
			; synonym for right
			vertical [
				position + ( dimension - min-size * 1x0) ;- 1x0
			]
		][0x0]
		
		;vout
	]
	
	;-----------------
	;-        !dimension-at-edge: []
	;
	; this is a purpose-built positioner for scrollers
	;
	; inputs:
	;    frame-position
	;    frame-dimension
	;    edge
	;    marble-min-size: based on edge, we will use x or y value.
	;-----------------
	!dimension-at-edge: processor '!dimension-at-edge [
		;vin [{!dimension-at-edge/process}]
		
		position: pick data 1
		dimension: pick data 2
		edge: pick data 3
		min-size: 1x1 * pick data 4 ; can be a width
		
;			    v?? position
;			    v?? dimension
;			    v?? edge
;			    v?? min-size
;			    
		
		plug/liquid: switch/default edge [
			; synonym for bottom
			horizontal [
				( dimension * 1x0) + (min-size * -1x1)
			]
			; synonym for right
			vertical [
				( dimension * 0x1) + (min-size * 1x-1)
			]
		][0x0]
		
		;vout
	]
	
			

	
	;-     !vertical-fill-dimension[]
	; inputs:
	;
	;   frame dimension
	;   frame min-size
	;   marble min-size
	;   marble fill-weight
	;   marble fill-accumulation
				
	!vertical-fill-dimension: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
				/local fd fms mms mfw mfa s
			][
				vin [{epoxy/!fill-dimension/process()}]
				

		
				plug/liquid: (1x0 * data/1/x ) + (0x1 * calculate-expansion data/1/y data/2/y data/3/y data/4/y data/5/y data/6/y data/7/y)
						
;				weight    2  1  3  0  2
;				regions  0  2 3   6  6  8
;				graph    |--|-|---|..|--|
;				(index    1  2  3     4 )
;				
;				example: 
;				--------				 
;				available 100
;				min-size   80
;				(extra     20)
;				
;				1.  (0 / 8) * 20 == 0
;				    (2 / 8) * 20 == 5 
;				    ------------------
;				    5 - 0 = min + 5  (5 / 20 total)
;				    
;				2.  (2 / 8) * 20 == 5
;				    (3 / 8) * 20 == 7.5 >> 8
;				    ------------------
;				    8 - 5 = min + 3  (8 / 20 total)
;				    
;				    
;				3.  (3 / 8) * 20 == 7.5 >> 8
;				    (6 / 8) * 20 == 15
;				    ------------------
;				    15 - 8 = min + 7 (15 / 20 total)
;				    
;				4.  (6 / 8) * 20 == 15
;				    (8 / 8) * 20 == 20
;				    ------------------
;				    20 - 15 = min + 5 (20 / 20 total)
				
				; is this marble statically sized?

					
					
				
				
				vout
			]
		]
	]


	;-     !horizontal-fill-dimension[]
	;
	!horizontal-fill-dimension: make !junction [
		valve: make valve [
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
				/local fd fms mms mfw mfa s
			][
				vin [{epoxy/!fill-dimension/process()}]
				
				vprobe data

		
				plug/liquid: (1x0 * calculate-expansion data/1/x data/2/x data/3/x data/4/x data/5/x data/6/x  data/7/x) + (0x1 * data/1/y)
						
		
				
				
				vout
			]
		]
	]
	
	
	
	;-         range-clip:
	; a plug which expects to be piped and uses linked inputs as the range and type
	; of value to share.
	range-clip: make !plug [
		linked-container?: true
		
		;-----------------
		;-         process()
		;-----------------
		process: func [
			plug
			data
		][
			vin [{process()}]
			plug/liquid: 1
			if all [
				number? value: pick data 1
				number? min: pick data 2
				number? max: pick data 3
			][
				
			]
			
			
			vout
		]
	]
	
	
	
	;-----------------------------------
	;-     !range-scale:
	;-----------------------------------
	; 
	;  allows to apply the rule of threes to an amount based on a scale and a min/max range.
	;
	; inputs (unlabeled):
	;     minimum-value:  (integer! decimal! ) 
	;     maximum-value:  same 
	;     amount:         a value within range of min/max (clipped to range as a precaution)
	;     scale:          scale of amount vs min/max range. (number! or pair!)
	;
	; details:
	;     the range is inclusive and is simply max - min
	;
	;-----------------------------------
	!range-scale: make !plug [
	
		;-     normalize-counter-scale?:
		;
		; when the scale scale is a pair, it will make sure the result is at least
		; the same amount as the smallest of the two values.
		;
		; this is used for scrollbars, for example to make sure that the knob is 
		; at least square.
		normalize-counter-scale?: true
		
	
		valve: make valve [
			type: 'range-scale
	
			;-----------------
			;-         process()
			;-----------------
			process: func [
				plug
				data
				/local min-val max-val scale amount range
			][
				vin [{range-scale/process()}]
				plug/liquid: either all [
					number? min-val: pick data 1
					number? max-val: pick data 2
					number? amount: pick data 3
					any [
						number? scale: pick data 4
						pair? scale
					]
					
				][
				
					;?? amount
					range: (max-val - min-val) + 1
					amount: min max 0 amount range
					
					;?? min-val
					;?? max-val
					;?? amount
					;?? range
					;?? scale
					
				
					; all is set
					either (0.0) <> (1.0 * amount) [
						(amount / range * scale)
					][
						; adapts to various scale datatypes
						0 * scale
					]
				][
					either scale [
						0 * scale
					][
						; this default may be dangerous as the amount might be expecting another output type.
						0
					]
				]
				
				if plug/normalize-counter-scale? [
					if pair? scale [
						min-val: min scale/x scale/y
						plug/liquid: max plug/liquid 1x1 * min-val
					]
				
				]
				
				vout
			]
		]
	]
	
	
	;-----------------------------------
	;-     !offset-value-bridge:
	;-----------------------------------
	;
	; <TO DO> directly support min/max of type:  pair! tuple!
	;
	; this plug is designed to provide a relationship between spacial coordinates and
	; a single value range.  
	;
	; it is setup as bridge because spacial and value and range are usually unequal but equivalent.
	;
	; channels: 
	;     'offset: the spatial value, bound to 0x0 -> (dimension)
	;     'value:  the data value, rounded and bound to min/max inputs
	;     'ratio:  a 0-1 scaled version of value/min/max. easier to use in code. When bar is full, value is 0.
	;     
	; inputs (unlabeled):
	;     minimum-value:  scalar,  acceptible types (integer! decimal! ) 
	;     maximum-value:  same as minimum-value
	;     range:          spatial range of offset (pair!)
	;     orientation:    tells the bridge, what value in spatial pair to apply (X or Y)
	;
	; details:
	;     minimum-value is inclusive and will be used when offset = 0
	;     maximum-value is inclusivee and will be used when offset = range
	;     when range = 0, minimum-value is used.
	;
	;     when used with a scroller knob, the supplied size should remove knob dimension from marble dimension.
	;     your are thus left with the scrollable part of the scroller range.
	;
	;     the knob dimension should also be linked to min/max/value/dimension, so that is scales automatically.
	; 
	;-----------------------------------
	!offset-value-bridge: make !plug [
		
		valve: make valve [
		
			type: 'epoxy-value-bridge-client
		
			pipe-server-class: make !plug [
			
				;-         current-value:
				current-value: 0
				
			
			
				; the pipe-server expects to be linked to other values.
				resolve-links?: 'LINK-AFTER

				valve: make valve [
			
					type: 'OFFSET-VALUE-BRIDGE
				
					pipe?: 'bridge
					
					;-----------------
					;-         process()
					;-----------------
					process: func [
						plug
						data
						/channel ch
						/local val off space min-val max-val tmp-val orientation vertical? ratio loff
					][
;						print "^/"
						;vin [{scroller bridge process()}]
;						?? ch
;						?? data
						val: 0
						off: 0x0
						
;						print ["current " plug/current-value]
						min-val: pick data 2
						max-val: pick data 3
						space: pick data 4
						orientation: pick data 5
						
;						?? min-val
;						?? max-val
;						?? orientation
;						?? space
						
						; fix min-max if they are inverted
;						if max-val < min-val [
;							tmp-val: max-val
;							max-val: min-val
;							min-val: tmp-val
;						]
						
						val-range: max-val - min-val
;						?? val-range
						 
						vertical?: 'vertical = any [orientation orientation: 'vertical]
;						?? orientation
						
						space: any [
							all [vertical? space/y]
							space/x
						]
						
						; if ch is set, it means the mud was set directly.
						; otherwise it means links changed.
						switch/default ch [
							; position
							offset [
								;print "setting value from offset"
								; make sure value is within bounds of scroller
								off: first first data
								
								val: any [
									all [space = 0 min-val]
									all [
										vertical?
										any [
											all [ integer? val-range round/floor (val-range / space * off/y + min-val)]
											all [ (val-range / space * off/y + min-val)]
										]
									]
									any [
										all [ integer? val-range round/floor (val-range / space * off/x + min-val)]
										all [ (val-range / space * off/x + min-val)]
									]
								]
							]
							value [
								;print "setting offset from value"
								val: first first data
								if string? val [
									either integer? val-range [
										val: any [attempt [to-integer val] 0]
									][
										val: any [attempt [to-decimal val] 0]
									]
								]
								;?? space
								;?? val
								off: 1x1 * any [
									;all [space = 0 0x0] ; bar is full enforce to top.
									all [ val-range = 0 0x0]
									all [1x1 * space *  ((val - min-val) / val-range)]
								]
							]
						][
							;print "value-offset-bridge has no mud to use"
							
							;print "I should scale offset to new dimension or values"
							val: any [plug/current-value 0]
							off: 1x1 * any [
								all [ val-range =  0 0x0]
								all [1x1 * space *  ((val - min-val) / val-range)]
							]
						]
						
						space: either vertical? [space * 0x1][space * 1x0]
						
						; make sure offset doesn't go out of bounds (works in both directions)
						off: max min space off 0x0
						loff: either vertical? [off/y][off/x]
						
						; make sure the value doesn't go out of bounds
						val: max min val max-val min-val
						
						; calculate ratio
						
						ratio: any [
							all [val-range = 0 0]
							(val - min-val  ) / val-range
						]
						
;						print "scroller"
;						?? min-val
;						?? max-val
;						?? val
						
						; remember the value so we can use it for unchanneled processes.
						plug/current-value: val
						
						plug/liquid: compose/deep [ 
							value [(val)] 
							offset [(off)] 
							ratio [(ratio)] 
							linear-offset [(loff)]
						]
						plug/mud: none
						;print "------>"
						;print ["value-range bridge: " mold plug/liquid]
						;print "------>"
						;vout
					]
				]
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

