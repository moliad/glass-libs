REBOL [
	; -- Core Header attributes --
	title: "Glass core utilities"
	file: %glass-core-utils.r
	version: 1.0.0
	date: 2015-1-21
	author: "Maxim Olivier-Adlhoch"
	purpose: {Low-level components  and functions used by many GLASS modules}
	web: http://www.revault.org/modules/glass-core-utils.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'glass-core-utils
	slim-version: 1.2.7
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/glass-core-utils.r

	; -- Licensing details  --
	copyright: "Copyright © 2015 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2015 Maxim Olivier-Adlhoch

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
		v1.0.0 - 2015-01-21
			- library created.
	}
	;-  \ history

	;-  / documentation
	documentation: {
		This library stores arbitrary code which has no linkable dependencies.
		
		This does not mean you cannot manipulate datasets from the other modules.
		
		It should only contain functions which need to be used accross other Low-level modules.
	}
	;-  \ documentation
]





;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'sillica
;
;--------------------------------------

slim/register [


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
	
	
]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

