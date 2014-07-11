CKEDITOR.plugins.add('CodeHighLighter',
{
    init: function (editor) {
        // Add the link and unlink buttons.
        editor.addCommand('CodeHighLighter', new CKEDITOR.dialogCommand('CodeHighLighter')); //定義dialog，也就是下面的code
        editor.ui.addButton('Code',     //定義button的名稱及圖片,以及按下後彈出的dialog
        {                               //這裡將button名字取叫'Code'，因此剛剛上方的toolbar也是加入名為Code的按鈕
            label: '插入高亮程式碼',
            icon: '/images/icon/codeicon.png',
            command: 'CodeHighLighter'
        });
        //CKEDITOR.dialog.add( 'link’, this.path + 'dialogs/link.js’ ); 
        //dialog也可用抽離出去變一個js，不過這裡我直接寫在下面
        CKEDITOR.dialog.add('CodeHighLighter', function (editor) {      
        //以下開始定義dialog的屬性及事件          
            return {                        //定義簡單的title及寬高
                title: '插入程式碼',
                minWidth: 500,
                minHeight: 400,
                contents: [              
                    {
                        id: 'code',
                        label: 'code',
                        title: 'code',
						//text: "123333",
                        elements:              //elements是定義dialog內部的元件，除了下面用到的select跟textarea之外
                            [                  //還有像radio或是file之類的可以選擇
							{
                                type: 'html',/*style="background-color:blue;"*/
                                html: '<p style="background-color:#dff0d8;font-size:14px;padding-top:3px;padding-bottom:3px;font-weight:bold;">請注意，在此處以及編輯器中皆不會顯示套用的格式，完成送出後才會顯示</p>',
                                id: 'language',
                                //required: true,
                                //'default': 'c',
                                //items: [['C', 'c'],['C++', 'cpp'],['Java','java'] ,['Ruby', 'ruby'],['Python', 'python'],['JavaScript', 'js'], ]
                            }
                            , {
                                id: 'codecontent',
                                type: 'textarea',
                                label: '請輸入程式碼',
                                style: 'width:700px;height:500px',
                                rows: 30,
                                'default': ''
                            }
                            ]
                    }
                    ],
                onOk: function () {                                    
                    //當按下ok鈕時,將上方定義的元件值取出來，利用insertHtml
                    //將組好的字串插入ckeditor的內容中
					var code = this.getValueOf('code', 'codecontent');    
                    //var lang = this.getValueOf('code', 'language');
					code = code.replace(/</gi, "&lt;");
					code = code.replace(/>/gi, "&gt;");
					var code_div='<pre class="prettyprint linenums:1">';
					editor.insertHtml(code_div+code+"</pre>");
					/*$.ajax({
						type: "GET",
					    url: '/post/getcode',
						data: {code: code,//main or sub
							   lang: lang, //comment id
						},
						dataType: 'json',
						success: function(data) {
							//$("#file_"+id).text(data);
							//alert(data);
							//alert(JSON.stringify(data, null, 4));
							editor.insertHtml( data.code );
						},
						error: function(){
							alert("ERROR");
						}
					});*/
                     
                     
                }
           };  
       });
    }
})