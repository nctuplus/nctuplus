/*
 *
 * Copyright (C) 2015 NCTU+
 *
 * For courses shopping cart
 *
 * Modified at 2018/5/28
 */

function add_to_cart($this_but, id,type){
    $.ajax({
        type: "GET",
        url : "/courses/add_to_cart",
        data : {
            cd_id:id,
            type:type
        },
        success : function(data){
            toastr[String(data.class)]( String(data.text) );
        }
    });
}

// 拿取使用者的收藏課程(json格式)
//  參數介紹:
//      success(data): 成功拿取時的callback function.
//          data: 拿到的使用者收藏課程(json)
function fetch_user_cart(success){
    $.ajax({
        type:'GET',
        url:'/courses/show_cart?view_type=session&use_type=delete&add_to_cart=0',
        headers:{
            'Content-Type':'application/json'
        }
    }).done(
        function(res){success(res);}
    )
}

