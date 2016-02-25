REBOL [
	; -- Core Header attributes --
	title: "Glass icon button marble"
	file: %style-icon-button.r
	version: 1.0.2
	date: 2013-9-17
	author: "Maxim Olivier-Adlhoch"
	purpose: "A button with graphics."
	web: http://www.revault.org/modules/style-icon-button.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'style-icon-button
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/style-icon-button.r

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
		v1.0.2 - 2013-09-17
			-License changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: {
		this style is useful to create icon buttons.  icons may have text or not, and by manipulating the different aspects, you can
		pretty much have the look that you want, including with or without text under the image.
		
		If you give it two different images in the spec, it will automacically become a toggle button by default.}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'style-icon-button
;
;--------------------------------------

slim/register [
	;- LIBS
	glob-lib: slim/open/expose 'glob none [!glob to-color]
	
	marble-lib: slim/open 'marble none
	button-lib: slim/open 'style-button none
	event-lib: slim/open/expose 'event none [dispatch]
	
	liquid-lib: slim/open/expose 'liquid none [
		!plug 
		[liquify* liquify ] 
		[content* content] 
		[fill* fill] 
		[link* link] 
		[unlink* unlink] 
		[dirty* dirty]
		processor
		liquify
	]
	
	
	sillica-lib: sl: slim/open/expose 'sillica none [
		master-stylesheet
		alloc-marble 
		regroup-specification 
		list-stylesheet 
		collect-style 
		relative-marble?
		prim-bevel
		prim-x
		prim-label
		prim-knob
		top-half
		bottom-half
		do-event
		do-action
		clip-to-marble
	]
	epoxy: slim/open/expose 'epoxy none [!box-intersection]
	glue-lib: slim/open 'glue none

	
	; we do not load the icon-lib immediatetly, since we cannot guess what 
	; icon set the app needs.
	;
	; instead, whenever the dialect detects an icon, it will load the lib dynamically
	; expecting the user to have select the set if its not the default.
	icon-lib: none

	
	
	
	;--------------------------------------------------------
	;-   
	;- GLOBALS
	;
	;-    default-icon:
	; this is the default glass marble image
	default-icon: make image! [32x32 #{
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000009BB3B9
7B96AE6E8EB06B8EB3799BBB8FAEC3ADC4C8C9D8D1000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000009CB3BD
5B7FB54774BD4B7EC84E89D24E88D1508BD15691D76396D27DA7D0ACC6D5
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000D1E2D8
80A0C24F7FC6548CCC5F96D4619CDD639DE35D9CDE60A0E266A4E768A3E4
6AA5E770A5E598BEDCC9DBD5000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
D6E5DE7FA2CD5388D16198D769A0DB6AA4E067A4E566A2E85FA1E964A4EB
68A6EB6BA9EC6DACEC6EAEEF72AEF097C2E8CCDDD4000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000009CB5CE5B8CD4679AD975A8E180B4EB7EB3EE74AEEB63A2E6
5C9EE561A1E561A4E966A9EE6CACEF6FB0F274B5F479B7F9A4CAE8000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000C4D6D46C97CF6698DB7AAAE492BFF095C3F28FBFF1
83BAEF63A3E95FA0E863A3EB61A6ED64A7ED66AAEE6CADF171B3F576B8FB
86C2FCB4CED66B8D8E171719000000000000000000000000000000000000
000000000000000000000000000000A1BBD26596D670A2E08DBCF19FCBF7
A2CEF59AC8F589BEF560A4F05CA4F061A6F162A7F264AAF166A8EF68ACF2
6FB1F678B7F981C2FF9ECCEC5F7A7C566C6F526A6B1B1C1F151618000000
000000000000000000000000000000000000D8E8DF89AAD2679BDB79ACE4
97C3F5A4CFF9AED8F8A1CFF97DB9F55BA1F15BA4F05FA6F061A6F364A9F3
67AAF167ABF16EB0F774B5F77EBDFB92CBFC80979A5C75765973745A7676
171719161618000000000000000000000000000000000000D0E1DF7FA6D3
6B9EDD7CAFEB94C3F59ECBF7A1CFF998C9FA74B0F35B9FEF5FA2EC62A5EE
65A7F365A9F565ABF367AAEE6AACF472B4F97CBEFC90CDFF98B4C2597072
576D6F5971733E4C4F1F1E211D1C1F1A1A1E19191B000000000000000000
C9DDDB7DA6D46EA2DE77ABE88ABBEF93C3F291C1F584BAF563A5ED62A7F0
5699E05C9FEC65A5F163A8F262A7F263A7EE69ACF272B5F97FC0FE8DCCFF
93B8CC617B7F54686A4C5C5F4D5F623A46491E1F221D1D201D1D20000000
000000000000CADFDD83A9D474A6DF6EA8E47BB1E984B7EB80B5EE6BA8EC
559CE75D9FE85499E4589EE85CA3EC60A4EE65A6EF65A7EE69ACF372B5F9
80C2FD8BCDFF8CB5CF72929D607A82566B704451544F6264222226212125
2021241E1E22000000000000D4E7E18AAED57AA8E06BA6E36DA7E470A8E7
6CA6E7579BE65097E65A9AE55FA0E75EA1EC5CA0EC60A3ED66A5ED67A6EE
69ACF274B6FA82C4FE8CCCFF88B2CE7CA0B57292A5678392566A744F6267
383F4328282C26262A232327000000000000E2F1E997B7D479A9DF75A8E0
69A4E2629FE25C9BE25296E25898E45D9DE65C9FE85C9FEC5EA0EC62A3ED
67A5F166A9EE6CB0F478BAFA86C7FF88C7FE89B5D182ABC77DA3BE7799B3
6D8CA35C7280434D552E2E332D2E3229292E000000000000000000B2CAD5
7CA8DA7BAAE273A7E562A0E15596DD5395E05495E45A99E65A9BE95C9FE8
5DA1E963A3F068ABF46DADF072B2F57EBFFC88C5FF89C4F696C9DD86B4D3
7EABCC7EA5C5789CB86C89A05A6F7E3B4047323338303035000000000000
000000D6E5E28BAED17AAEE477AAE676A9E869A3E6609BDF5D99E35A99E4
5A9DE75DA1E862A2E76CABF16FAEF470AFF279B8FA81C1FF79B5F6AAE2F3
A6DBE88DC0DF7DADD57BA6CA7DA1C27698B36A859A4C576335353C34353A
000000000000000000000000B3C8CE7DA9D47AB0E978ABE673AAE76CA6E8
69A0E564A0E563A3E766A3E969A6E96FACED71B0F378B7FA7FC0FD79B3ED
8EC9F3B9F1F0ACE3EA94C8E27DAFD979A6CD7BA1C2799BB97291A95D7285
3F454D36373C000000000000000000000000E0F2E89CB2B877A0CB7BB0E5
76AFE874ACEC6FA8E96CA6EB6AA6ED6BA9EC6DACEF74B2F47AB9FC7BB9F3
69A0D982BAE8BFF3F5B9EFEFADE2E794C6DE7DAED775A3CC769CBD779AB7
7494AE677F974D57653A3B40000000000000000000000000010101D3E5DC
9AAAAF7391AF73A1CC74A9E172ADE973ADF076B0F273AFEE71B0EE70A7D6
618AB15480AF78B1DEC0F6F7BEF1F1B3EAEAA7DADF8DBCD67AA8D0739FC7
7397B87595B17392AC6B869D58687A434952000000000000000000000000
0403045A7173B2C8C1ABBDBE7D929E67829660839C6387A75C83A35F89AE
5471883C4B5B4C6E9B8EC8E6BAF0F3BBEFF0B4EAE9ABDEE099C8D583AECE
75A2CA6F98BF6F91B27190AA708DA76C87A05F7487515C6B000000000000
000000000000030303586F71617E805E787AA2B7B696A8AB717F825B6669
5159654F5E6C4E5F756992BE97CEE3A6D9E2ABE0E5AADEE3A2D4DB96C4D4
85B0CC78A2C8719BC56B92BA6C8EB06E8BA76F8BA56A849D647A90657D93
0000000000000000000000000000002323273D4C4F638182546B71607987
56697645597049668F516F996284A8739EBD7DABC78AB8CE93C3D393C1D0
8CB7CB82ACC47AA2C2739AC06B91BA698EB46A8BAC6D89A56E89A26C87A0
69839B7291AD0000000000000000000000000000001C1C1F212125495D5E
3A484E44545E4A5A664C5F74526A895E7B9B6B8DAF6D91AF6A90AE7198B5
78A0BA7AA1BB789EB97297B46B8FB16688AC6688AC6686A766819E677F96
677F966881986F8BA67FA6C600000000000000000000000000000018181B
22222618191B18191B2B3138353D443E485347525F576674607487596E85
5268825A7490607C9763809D617C995F79955D76925F7894607A97617994
5E71865B687A55627161768A7CA1C18CBAE0000000000000000000000000
00000000000025252918181A1516181D1D1F21212533384035383F34343A
39393E3D3E4444465049505D4B55664D586A4D56654F5766515D6D566477
576779576578545F6E505B674E576353616F779AB88CBAE0000000000000
00000000000000000000000000000000000012121319191C1E1E20353C44
3A404831313637383D3C3C4240404744444B46474E48485047485047484F
4B505A525C695A697A5B6C7C5563723D3E44464C565565758CBAE08CBAE0
000000000000000000000000000000000000000000000000000000141517
1B1C1E1F1F22404B542D2D3333343938383E3B3B423F404642434A44454C
45464D45464E525A6644454C5561703F3F463D3D443B3B424D596761798F
8CBAE08CBAE0000000000000000000000000000000000000000000000000
0000000000001314164E64684F636854676F566972556873566775515E6A
535F6C607585617585698295708DA47493AE657D93657C92647B9162798F
60778D000000000000000000
} #{
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFB5
755A335772B2FDFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFA9
24000000000000001EA0
FFFFFFFFFFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFF7
5A000000000000000000
000054F4FFFFFFFFFFFF
FFFFFFFFFFFFFFFFFFFF
FD450000000000000000
00000000003CFAFFFFFF
FFFFFFFFFFFFFFFFFFFF
FFFF7200000000000000
000000000000000069FF
FFFFFFFFFFFFFFFFFFFF
FFFFFFDC030000000000
00000000000000000000
03CBFCFFFFFFFFFFFFFF
FFFFFFFFFF6600000000
00000000000000000000
00000053F6FAFDFFFFFF
FFFFFFFFFFFFFD120000
00000000000000000000
000000000008E9F5F8FB
FEFFFFFFFFFFFFFFD600
00000000000000000000
0000000000000000C1EE
F1F5FBFEFEFFFFFFFFFF
B8000000000000000000
00000000000000000000
9EE4ECF0F5FAFCFEFFFF
FFFFB500000000000000
00000000000000000000
00008ACEDAE7F0F5FAFC
FDFFFFFFD00000000000
00000000000000000000
0000000077A2B4CEE4EE
F7FBFDFFFFFFF7090000
00000000000000000000
0000000000015D7187A5
C7E0EFF9FCFEFFFFFF4E
00000000000000000000
000000000000000B384B
5C769FC2E1F3F8FCFFFF
FFC10000000000000000
00000000000000000012
223041587AA2CAE7F3FB
FFFFFFFF4E0000000000
00000000000000000000
04151F2C3B4D6886AFD6
EBF8FFFFFFFFEE230000
00000000000000000000
00010F162232404F687E
9DC5E5F6FFFFFFFFFFDE
2C000000000000000000
0000020D131E2E3E4A5B
71879FBFE0F6FFFFFFFF
FFFDED65060000000000
0000010C1719202E414D
57667C90A7C4E4F8FFFF
FFFFFFFDF9F6D2733110
00060E273B3731313B48
565E6977889FB5CEE9FA
FFFFFFFFFFFEFBF7F3EA
D4BA90645059625A5554
5B666D75838D9CB1C3D7
ECFAFFFFFFFFFFFEFDF9
F7F3EADBC4A38988918B
8281848A929AA2AAB7C6
D5E2F0FAFFFFFFFFFFFF
FDFBFAF7F3EFE6D7CAC9
C8BFB4B4B5B9BFC2C7CF
D6DDE7EEF6FCFFFFFFFF
FFFFFFFDFBF9F9F6F4F2
EEEBE5E1DEDCDDDEE2E6
E8EBEFEDF1F9FCFDFFFF
FFFFFFFFFFFFFEFBFBF9
F8F9F6F3F1F0EFEEEEF0
F3F5F6F7F9F8F8FDFEFF
FFFFFFFFFFFFFFFFFFFF
FDFCFBFDFCFAF9F8F8F9
F8FAFAFDFCFDFDFDFCFE
FFFFFFFFFFFFFFFFFFFF
FFFFFFFDFDFDFDFDFDFC
FCFBFBFAFBFDFEFEFEFE
FEFFFFFF
}]
	
	


	
	;--------------------------------------------------------
	;-   
	;- !ICON-CHOOSER [ ]
	!icon-chooser: processor '!icon-chooser 
	[
;		vin "!ICON-CHOOSER/process"
		selected?:     pick data 1
		hover?:        pick data 2
		engaged?:      pick data 3
		
		icon:          pick data 4
		engaged-icon:  pick data 5
		hover-icon:    pick data 6
		selected-icon: pick data 7
		
;		v?? selected?
;		v?? hover?
;		v?? engaged?
;		vprint ["selected?: " type? selected? ]
;		vprint ["hover?: " type? hover? ]
;		vprint ["engaged?: " type? engaged? ]
;		vprint ["icon: " type? icon ]
;		vprint ["engaged-icon: " type? engaged-icon ]
;		vprint ["hover-icon: " type? hover-icon ]
;		vprint ["selected-icon: " type? selected-icon ]
		
		
		plug/liquid: any [
			all [ engaged?  engaged-icon  ]
			all [ selected? selected-icon ]
			all [ hover?    hover-icon    ]
			icon
		]
		
;		vout
	]
	
	
	


	;--------------------------------------------------------
	;-   
	;- !ICON[ ]
	!icon: make button-lib/!button [


		;--------------------------
		;-    default-data-aspect:
		;
		; the icon uses the engaged? aspect to tell you if its on or off.
		;--------------------------
		default-data-aspect: 'engaged?

	
		;-    Aspects[ ]
		aspects: make aspects [
			;--------------------------
			;-         engaged?:
			;
			; is this icon toggled and engaged?
			;--------------------------
			engaged?: none
			
			
			;-         icons
			; icon used by default 
			icon: default-icon
			engaged-icon: none  ; when set to an image, the icon becomes a toggle button.
								; when two icons are specified in dialect spec, the second one is used for the toggled image
								; and automatically activates toggle mode
			hover-icon: none
			selected-icon: none  ; 
			
			
			options: [ simple ] ; this includes modes and hints for display.
			drawing: none ; this is a special AGG draw block you include over the rest, but under the shine.
			icon-spacing: 0x0 ; this adds space between the text and the icon (you shoudn't add any x component here, it must be a pair).
			padding: 3x3
			label: none
			size: -1x-1  ; -1 in any coordinate makes it auto-sizing (on attach/detach)
			font: theme-menu-item-font
		]

		
		
		;-    Material[]
		material: make material [
			fill-weight: 0x0
		
			
			;-        icon-size:
			; this node will connect to the icon and return only its size.
			; this will thus force the button to add the icon's size to itself
			icon-size: none
			
			
			;-        label-size:
			; space setup for label (this will be used instead of usual min-dimension)
			; and min-dimension will be a pair-add node
			label-size: none
			
			
			;-        icon-spacing:
			; because materials have precedence in linking, this icon-space will be used instead
			; of the aspect.
			;
			; this will be linked to the aspect, but will be gated to that its only active
			; when there is a label
			icon-spacing: none
			
			;-        inside-size:
			; 
			; this is the custom calculated size of the icon icluding image, label and spacing, but not padding.
			;
			; padding is calculated in min-dimension directly.
			inside-size: none
			
			
			;-        image
			; the actual image being shown, will usually be a link to one of the various icon aspects (which are images)
			image: none
			
			
			;--------------------------
			;-             auto-size:
			;
			; automatically calculated size based on icons, text,  padding, etc.
			;--------------------------
			auto-size: none
		]
		
		
		;-    label-auto-resize-aspect:
		; this will resize the width based on the text, automatically.
		label-auto-resize-aspect: 'automatic
		
		
		;-    icon-set:
		; this will change the default icon set used when the DIALECT is evaluated.
		;
		; none uses the icons lib default
		;
		; use this to create substyles which refer to different icon sets by default.
		;
		; this can actually be the same icons but with different scalings or styles depending
		; on where they are used.
		icon-set: none
		
		
		;--------------------------
		;-             direction:
		;
		; 
		;--------------------------
		direction: 'vertical
		
		
		
		
		;-    radio-list:
		; when this is filled with a block containing other marbles,
		; they will automatically be switched to off when this one is set to on.
		radio-list: none
		
		
		;-    valve[ ]
		valve: make valve [
		
			type: '!marble
		
			;-        style-name:
			; used as a label for debugging and node browsing.
			style-name: 'icon  
			
			
			;-        label-font:
			; font used by the gel.
			;label-font: theme-knob-font
			
			;-        glob-class:
			; defines the glob which will be built by each marble instance.
			;   glob-class/marble  is added automatically by setup.
			glob-class: make !glob [
				pos: none
				
				valve: make valve [
				
					;-----------------
					;-        mode()
					;-----------------
					mode: func [
						selected?
						label?
						icon?
					][
						any [
							all [selected? icon? label?  'both-down ]
							all [selected? icon? 'icon-down]
							all [selected? label? 'lbl-down]
							all [icon? label? 'both-up]
							icon? 'icon-up
							label? 'lbl-up
						]
					]
					
					; binding for gel spec
					tmp: none
				
					;-            glob/input-spec:
					input-spec: [
						; list of inputs to generate automatically on setup these will be stored within glob/input
						position !pair (random 200x200)
						dimension !pair (100x30)
						color !color  (random white)
						label-color !color  (random white)
						label !string ("")
						;focused? !bool
						hover? !bool
						!bool
						hidden? !bool
						selected? !bool
						engaged? !bool
						align !word
						padding !pair
						font !any
						image !any ; MUST be an image! or none!
								  ; dimension will always add enough space for the image & text.
						label-size !any
						icon-spacing !any
					]
					
					;-            glob/gel-spec:
					; different AGG draw blocks to use, one per layer.
					; these are bound and composed relative to the input being sent to glob at process-time.
					gel-spec: [
					
					
						; event backplane
						position dimension hidden?
						[
							(
								either data/hidden?= [
									[]
								][
									compose [
										line-width 1 
										pen none 
										fill-pen (to-color gel/glob/marble/sid) 
										box (data/position=) (data/position= + data/dimension= - 1x1)
									]
								]
							)
						]
						
						; bg layer (ex: shadows, textures)
						; keep in mind... this can be switched off for greater performance
						;[]
						
						; fg layer
						position dimension color label-color label align hover? hidden? selected? padding font image label-size icon-spacing 
						[
							(
								either data/hidden?= [
									[]
								][
									compose [
										
										; BG
										(
											either (data/selected?= and data/hover?=) [
												compose [
													; edge color
													pen black
													fill-pen none 
													line-width 1
													box (data/position=) (data/position= + data/dimension= - 1x1) 3
													
													;inner shadow
													pen (shadow + 0.0.0.25)
													line-width 2
													fill-pen none
													box (data/position= + 1x1) (data/position= + data/dimension= - 2x2) 2
			
													pen none
													(sl/prim-glass/corners/only (data/position= + 1x2) (data/position= + data/dimension= - 1x1) (theme-color + 0.0.0.50) 190 2)
												]
											][[]]
			
										)
										(
											either ((not data/selected?=) and data/hover?=) [
												compose [
													fill-pen (white + 0.0.0.180)
													pen ( theme-knob-border-color  + 0.0.0.75 )
													line-width 1
													box (data/position=) ( data/position= + data/dimension= - 1x1 ) 3
												]
											][[]]
										)
										(
											either image? data/image= [
												either gel/glob/marble/direction = 'vertical [
													ori: 1x0
													ctr-ori: 0x1
												][
													ori:  0x1
													ctr-ori: 1x0
												]
												
												 tmp: (data/position= + (data/dimension= / 2 * ori) - (data/image=/size / 2 * ori)  ) + 
													  ((data/dimension= - data/label-size= - data/icon-spacing= - data/image=/size) / 2 * ctr-ori)
													
												compose [
													pen none
													fill-pen none
													
													;IMAGE-FILTER NEAREST
													image (data/image=) (tmp)
													; uncomment to put a red box around the image. allows to debug sizing algorythm.
													;pen red
													;line-width 1
													;fill-pen none
													;box (tmp: (data/position= + (data/dimension= / 2 * 1x0) - (data/image=/size / 2 * 1x0) + (data/padding= * 0x1) )) (tmp + data/image=/size - 1x1 )
												]
											][[]]
										)
										
										line-width 2
										pen none
										fill-pen (data/label-color=)
										
										; label
										(ori: either gel/glob/marble/direction = 'vertical['bottom]['right] prim-label/pad data/label= data/position= + 1x0 data/dimension= data/label-color= data/font= ori data/padding=)
										
										
									]
								]
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
			;-        post-specify()
			;-----------------
			post-specify: func [
				toggle
				stylesheet
			][
				vin [{post-specify()}]
				if block? toggle/radio-list [
					append toggle/radio-list toggle
				]
				vout
			]
			


			

			
			
			;-----------------
			;-        icon-handler()
			;-----------------
			icon-handler: funcl [
				event [object!]
			;	/local button  marble toggle? return-event engaged?
			][ 
				vin [{ICON HANDLER}]
				vprint event/action
				icon: event/marble
				
				; just check if we are in toggle mode or not.f
				if content* icon/aspects/engaged-icon [
					toggle?: true
				]
				
				action-event: event
				
				switch/default event/action [
					start-hover [
						clip-to-marble event/marble event/viewport
						fill* icon/aspects/hover? true
					]
					
					end-hover [
						clip-to-marble event/marble event/viewport
						fill* icon/aspects/hover? false
					]
					
					select [
						fill* icon/aspects/selected? true
						either toggle? [
							vprint "toggle icon pressed!"
							
							engaged?: content* icon/aspects/engaged?
							v?? engaged?
							
							; is this part of a radio-list?
							either all [
								block? icon/radio-list
								not empty? icon/radio-list
							][
								; we cannot disengage a radio-list item by clicking on the currently
								; engaged one... only by pressing on an un-engaged one.
								;
								; note that the radio-list may contain ANY marble which reacts to the 
								; TOGGLE? event.
								if not engaged? [
									togl-event: make event [new-toggle-state: false]
									togl-event/action: 'TOGGLE?
									;probe length? icon/radio-list
									foreach marble icon/radio-list [
										unless any [
											same? marble icon
											not true? content* marble/aspects/engaged? ; already off, don't switch it off.
										][
											togl-event/marble: marble
											dispatch togl-event
										]
									]
									togl-event: none ; GC cleanup
								]
							][
								; normal toggle icon
								event: make event [
									new-toggle-state: not engaged?
									action: 'TOGGLE?
								]
								dispatch event
							]
						][
						
						]
					]
					
					
					;----
					; should we toggle? (this is a causation, not an effect.  we could refuse to engage.)
					;
					; we can refuse to toggle by explicitely returning a false value, in which case the 
					; TOGGLE event will never occur.
					;
					; note that returning #[none] or unset! will not prevent toggle, only #[false] .
					TOGGLE? [
						result: none ; declare for funcl 
						set/any 'result do-event event
						
						; we only prevent triggering the TOGGLE event if the do-action explicitely returns a #[false] value.
						unless all [
							logic? get/any 'result ; prevents errors when do-action returns a weird value like function! and unset!
							result  ==  #[false]
						][
							event/action: 'TOGGLE
							fill*  icon/aspects/engaged? event/new-toggle-state
							clip-to-marble event/marble event/viewport
							dispatch event
						]
						action-event: none
					]
					
					
					;----
					; TOGGLE the marble
					;
					; at this point, the marble IS toggled and the engaged? aspect will be 
					; triggered automatically, just before calling the marble's action
					TOGGLE [
						;update-icon event/marble
						do-action event
						action-event: none
					]
					

					;----
					; successfull click
					release [
						fill* icon/aspects/selected? false
						
						unless toggle? [
							do-action event
							action-event: none
						]
					]
					
					; canceled mouse release event
					drop no-drop [
						;fill* icon/aspects/selected? false
						;do-action event
					]
					
					swipe [
						fill* icon/aspects/hover? true
						;do-action event
					]
				
					drop? [
						fill* icon/aspects/hover? false
						;do-action event
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
					action-event: none
					vprint "IGNORED"
				]
				
				if action-event [
					do-event action-event
				]
				
				vout
				
				
				; can be the input event, a new event or none (by default) if we consume the event.
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
				event-lib/handle-stream/within 'icon-handler :icon-handler marble
				vout
			]
			

			
			;-----------------
			;-        materialize()
			; style-oriented public materialization.
			;
			; called just after gl-materialize()
			;
			; note materializtion occurs BEFORE the globs are linked, so allocate any
			; material nodes it expects to link to here, not in setup-style().
			;
			; read the materialize() function notes above for more details, which also apply here.
			;-----------------
			materialize: funcl [
				icon
			][
				mat: icon/material
				aspect: icon/aspects 
			
				vin [{glass/!} uppercase to-string icon/valve/style-name {[} icon/sid {]/materialize()}]
				mat/icon-size: liquify* epoxy/!image-size
				mat/icon-size/mode: 'xy ; we only want to add height to the button.
				
				mat/icon-size/resolve-links?: 'LINK-BEFORE ; should make the icon receptive to both links or fills
				
				
				
				mat/image: liquify*/link !icon-chooser reduce [
					aspect/selected?
					aspect/hover?
					aspect/engaged?
					
					aspect/icon 
					aspect/engaged-icon
					aspect/hover-icon
					aspect/selected-icon
				]
				
				; swap the allocated min-dimension for label-size
				mat/label-size: icon/material/min-dimension
				
				; allocate a new min-dimension which will be linked to other space requirements.
				mat/min-dimension: liquify* epoxy/!pair-max
				mat/inside-size: liquify* epoxy/!vertical-accumulate
				
				mat/icon-spacing: liquify* glue-lib/!gate
				mat/icon-spacing/default-value: 0x0
				
				mat/auto-size: liquify* epoxy/!pair-add
				
				vout
			]
			
			
			
			;-----------------
			;-        gl-fasten()
			; here we replace the gl-fasten, since we had to move min-dimension to some special setup
			;-----------------
			gl-fasten: func [
				marble
			][
				vin [{glass/!} uppercase to-string marble/valve/style-name {[} marble/sid {]/gl-fasten()}]
				
				; the automatic label resizing is optional in marbles.
				;
				; current acceptible values are ['automatic | 'disabled]
				if 'automatic = get in marble 'label-auto-resize-aspect [
					link*/exclusive marble/material/label-size liquify/fill !plug -1x-1 ; marble/aspects/size
					link* marble/material/label-size marble/aspects/label
					link* marble/material/label-size marble/aspects/font
					;link* marble/material/label-size marble/aspects/padding
				]
				
				
				
				; perform any style-related fastening.
				marble/valve/fasten marble
				vout
			]


			;-----------------
			;-        fasten()
			;
			; style-oriented public fasten call.  called at the end of gl-fasten()
			;
			;-----------------
			fasten: funcl [
				icon
			][

				
				vin [{glass/!} uppercase to-string icon/valve/style-name {[} icon/sid {]/fasten()}]
				; this causes massive slow down, since each icon state
				; causes a complete redraw of the backplate.
				mat: icon/material
				apct: icon/aspects
				

				if icon/direction = 'horizontal [
					; mutate the direction !! 
					mat/inside-size/valve: epoxy/!horizontal-accumulate/valve
				]

				fill* icon/material/icon-size content* icon/material/image
				
				; we only have icon spacing when there is a label.
				link* icon/material/icon-spacing icon/aspects/icon-spacing
				link* icon/material/icon-spacing icon/aspects/label
				
				link* mat/inside-size   reduce [ mat/icon-size  mat/icon-spacing  mat/label-size ]
				link* mat/auto-size     reduce [ mat/inside-size  apct/padding  apct/padding ]
				link* mat/min-dimension reduce [mat/auto-size apct/size]
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
			dialect: func [
				marble [object!]
				spec [block!]
				stylesheet [block!] "Required so stylesheet propagates in marbles we create"
				/local data img-count icon
			][
				vin [{dialect()}]
				img-count: 1
				issue-count: 1
				
				parse spec [
					any [
						set data issue! (
							unless icon-lib [ 
								icon-lib: slim/open 'icons none 
							]
							
							icon: icon-lib/get-icon/set to-word to-string data marble/icon-set
							
							switch issue-count [
								1 [
									link*/reset marble/aspects/icon icon
								]
								
								; second issue toggles the icon into toggle mode.
								2 [
									vprint "ICON  is now a TOGGLE"
								
									link*/reset marble/aspects/engaged-icon icon
								]
							]
							
							unless string? content* marble/aspects/label [
								fill* marble/aspects/label icon-lib/icon-label data
							]
							
							issue-count: issue-count + 1
						)
						
						| 'no-label (
							fill* marble/aspects/label none
						)
						
						| 'horizontal (
							marble/direction: 'horizontal
						)
						
						| ['on | 'true | #[true]] (
							fill* marble/aspects/engaged? true
							;update-icon marble
						)

						| ['off | 'false | #[false]] (
							fill* marble/aspects/engaged? false
							;update-icon marble
						)
						
						| set data image! (
							switch img-count [
								; sets the main image
								1 [
									fill* marble/aspects/icon data
									;fill* marble/material/image data
									img-count: img-count + 1
								]
								
								; sets the push image
								2 [
									img-count: img-count + 1
								]
								
								; sets the hover image
								3 [
									img-count: img-count + 1
								]
							]
						)

;----------------------------------------------------------------------------------------------------
;                       ; WILL NOT WORK BECAUSE OF THE WAY THE MARBLE IS CURRENTLY MATERIALSED AND FASTENDED
;----------------------------------------------------------------------------------------------------
;						| 'img-size set data pair! (
;							print "========================="
;							print "MANUAL icon IMG size"
;							print "========================="
;							; detect if we want proportional sizing...
;							if any [
;								-1 = data/x
;								-1 = data/y
;							][
;								print "MANUAL PROP"
;								either data/x = -1 [
;									
;								][
;							
;								]
;							]
;						)
;----------------------------------------------------------------------------------------------------
						
						| skip
					]
				]

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

