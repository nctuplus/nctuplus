class NewcomerController < ApplicationController
	def curricular
		@title = "社團資訊 | 網路新生包"
		@data = [
			{
				category: "curricular",
				name: "國際標準舞社",
				pdf: "國標.pdf",
				web: nil,
				fb: "https://www.facebook.com/NCTUBallroomDance/",
				img: "國標.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "網絡安全策進會",
				pdf: "網安.pdf",
				web: "https://bamboofox.github.io/",
				fb: "https://www.facebook.com/NCTUCSC",
				img: "網安.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "魔術社",
				pdf: "魔術社.pdf",
				web: nil,
				fb: "https://www.facebook.com/nctuMagic/",
				img: "魔術.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "管弦樂團",
				pdf: "國立交通大學管弦樂團.pdf",
				web: nil,
				fb: "https://www.facebook.com/%E4%BA%A4%E5%A4%A7%E7%AE%A1%E5%BC%A6%E6%A8%82%E7%A4%BE-190643944351797/?fref=ts",
				img: "管弦樂.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "汪汪社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/%E4%BA%A4%E5%A4%A7%E6%B1%AA%E6%B1%AA%E7%A4%BE-486262641434965/?fref=ts",
				img: "汪汪.jpg",
				color: "white"
			},
			{
				category: "curricular",
				name: "虹韻世界民族舞蹈社",
				pdf: "交大虹韻民族舞蹈社.pdf",
				web: nil,
				fb: "https://www.facebook.com/nctufolkdance/",
				img: "交大虹韻民族舞蹈社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "劍道社",
				pdf: "劍道.pdf",
				web: "http://web.it.nctu.edu.tw/~nctukendo/qna.html",
				fb: "https://www.facebook.com/nctukendo/?fref=ts",
				img: "劍道.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "友聲社",
				pdf: "友聲社.pdf",
				web: "http://nctuyschorus.weebly.com/",
				fb: "https://www.facebook.com/nctuchorus/?fref=ts",
				img: "you-shang.png",
				color: "default"
			},
			{
				category: "curricular",
				name: "戲劇社",
				pdf: "戲劇社社團簡介.pdf",
				web: nil,
				fb: "https://www.facebook.com/dramaclubnctu",
				img: "戲劇社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "漫畫社",
				pdf: "漫畫社.pdf",
				web: nil,
				fb: "https://www.facebook.com/NCTUComicClub/",
				img: "漫畫社.jpg",
				color: "white"
			},
			{
				category: "curricular",
				name: "鐵道會",
				pdf: "交鐵會社團.pdf",
				web: nil,
				fb: "https://www.facebook.com/NCTURail",
				img: "鐵道會.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "星聲社",
				pdf: nil,
				group: "https://www.facebook.com/groups/540839232683099/",
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E9%80%9A%E5%A4%A7%E5%AD%B8%E6%98%9F%E8%81%B2%E7%A4%BE/106445842756224",
				img: "星聲社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "國術社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuMartialArt/",
				img: "國術社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "管樂團",
				pdf: "管樂團網路新生包.pdf",
				web: nil,
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E9%80%9A%E5%A4%A7%E5%AD%B8%E7%AE%A1%E6%A8%82%E5%9C%98/205591206145512",
				img: "管樂團.jpg",
				color: "white"
			},
			{
				category: "curricular",
				name: "國樂團",
				pdf: "國樂社介紹.pdf",
				web: nil,
				fb: "https://www.facebook.com/ilovenctucmc",
				img: "國樂社圖宣.jpg",
				color: "white"
			},
			{
				category: "curricular",
				name: "機車研究社",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NWGJkNS15S3duMjg/view?usp=sharing",
				group: "https://www.facebook.com/groups/nctumotor/",
				fb: nil,
				img: "交通大學機車研究社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "散打搏擊社",
				pdf: "散打搏擊社.pdf",
				group: "https://www.facebook.com/groups/130432718550/",
				fb: nil,
				img: "散打搏擊社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "創客俱樂部",
				pdf: "創客俱樂部.pdf",
				group: "https://www.facebook.com/groups/722749624403809/",
				fb: "https://www.facebook.com/Makereal.Labs/",
				img: "創客俱樂部.jpg",
				color: "default",
			},
			{
				category: "curricular",
				name: "設計與思考社",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NdS1pNzFCMnQ0eHM/view?pref=2&pli=1",
				web:"https://www.facebook.com/NCTUDT/",
				group: nil ,
				img: "design_think.png",
				color: "default"
			},
			{
				category: "curricular",
				name: "咖啡社",
				pdf: nil,
				group: "https://www.facebook.com/groups/nctucoffeeclub/",
				fb: "https://www.facebook.com/NCTUcoffee",
				img: "咖啡社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "梅竹後援會",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NdFFnTHYxb3B0Sk0/view?usp=sharing",
				group: "https://www.facebook.com/groups/560188640835522/",
				fb: "https://www.facebook.com/nctu.meichu/",
				img: "梅竹後援會.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "清交大烏克麗麗社",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NdDUtUHJnUFl2c1E/view?pref=2&pli=1",
				group: "https://www.facebook.com/groups/327026434028600/",
				fb: "https://www.facebook.com/NCTUXNTHUUkuleleClub?fref=nf&pnref=story",
				img: "清交大烏克麗麗社.jpg",
				color: "white"
			},
			{
				category: "curricular",
				name: "陶藝社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuceramic/?hc_ref=SEARCH&fref=nf",
				img: "陶藝社網路新生包.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "布袋戲社",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NV21iRWpXTG44bWc/view?pref=2&pli=1",
				web: nil,
				fb: "https://www.facebook.com/nctupdcfans",
				img: "交大布袋戲社.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "文化服務團",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/JiaoDaWenFuGeiNiSuoYou",
				img: "文化服務團.jpg",
				color: "default"
			},
			{
				category: "curricular",
				name: "社會企業創思社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctu.strong.2013",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "單車社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/werideourlife2015",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "山服社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctusanfupower",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "音樂遊戲社",
				pdf: "交通大學音樂遊戲社.pdf",
				group: "https://www.facebook.com/groups/1192450100778699/",
				fb: "https://www.facebook.com/nctumgc",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "攝影社",
				pdf: nil,
				group: "https://www.facebook.com/groups/196123263786384/",
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E5%A4%A7%E6%94%9D%E5%BD%B1%E7%A4%BE/163474003683212",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "橋藝社",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/178089168941413",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "桌上遊戲社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUBG",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "竹韻口琴社",
				pdf: "竹韻口琴社.pdf",
				web: nil,
				fb: "https://www.facebook.com/nctubmhc",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "慈青社",
				pdf: nil,
				group: "https://www.facebook.com/groups/nctu.tzuchi/",
				fb: "https://www.facebook.com/nctuclubtzuchi",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "鋼琴社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuPIANO",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "柏克萊學生團契",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/koinoniahsinchu",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "數位音樂創作社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUDMCC",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "動畫社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuanime",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "彩妝保養社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E9%80%9A%E5%A4%A7%E5%AD%B8%E5%BD%A9%E5%A6%9D%E4%BF%9D%E9%A4%8A%E7%A4%BE/120834974684983",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "登山社",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/NCTUmountain/",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "信望愛社",
				pdf: nil,
				group: "https://www.facebook.com/groups/265268466818755/",
				fb: "https://www.facebook.com/nctufhl",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "馬術社",
				pdf: nil,
				group: "https://www.facebook.com/groups/183634768487887/",
				fb: "https://www.facebook.com/nctuEC",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "吉他社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E5%A4%A7%E5%90%89%E4%BB%96%E7%A4%BE/138414562871595",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "柔道社",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/NCTUJUDO",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "AIESEC",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/AIESECNCTU",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "模擬聯合國社",
				pdf: nil,
				web: "http://www.nctumun.org/",
				fb: "https://www.facebook.com/nctumun",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "崇德青年志工社",
				pdf: nil,
				fb: "https://www.facebook.com/NCTUCDYoungVolunteers",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "創新創業社",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUIEC/",
				img: nil,
				color: "default"
			},
			{
				category: "curricular",
				name: "網路福利社",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/169489583068057/",
				img: nil,
				color: "default"
			}

		]
	end



	def studentAssociation
		@title = "系學會 | 網路新生包"
		@data = [
			{
				category: "studentAssociation",
				name: "工業工程與管理學系",
				pdf: "工業工程與管理學系-系學會新生通知.pdf",
				web: nil,
				fb: "https://www.facebook.com/IEMhome",
				img: "工業工程與管理學系.jpg",
				color: "grey",
				group: "https://www.facebook.com/groups/1724898754415038/"
			},
			{
				category: "studentAssociation",
				name: "生物科技學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctudbtsu/",
				img: "生物科技.jpg",
				group: "https://www.facebook.com/groups/1546915355611613/"
			},
			{
				category: "studentAssociation",
				name: "電機資訊學士班",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctu.eecs",
				img: nil
			},
			{
				category: "studentAssociation",
				name: "奈米科學及工程學士學位學程",
				pdf: "奈米系學會.pdf",
				web: "http://nanostu.weebly.com/",
				fb: nil,
				img: nil
			},
			{
				category: "studentAssociation",
				name: "電子工程學系",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil,
				group: "https://www.facebook.com/groups/1245254812158317/"
			},
			{
				category: "studentAssociation",
				name: "電機工程學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuECEStudentAssociation",
				img: nil
			},
			{
				category: "studentAssociation",
				name: "光電工程學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E5%A4%A7%E5%85%89%E9%9B%BBNCTU_EO/201908786557647",
				img: nil,
				group: "https://www.facebook.com/groups/183222062072883/"
			},
			{
				category: "studentAssociation",
				name: "資訊工程學系",
				pdf: nil,
				web: "https://www.nctucs.tw/",
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E5%A4%A7%E8%B3%87%E5%B7%A5%E7%B3%BB%E5%AD%B8%E6%9C%83/177647505627076",
				img: nil,
				group: "https://www.facebook.com/groups/NCTUCS109/"
			},
			{
				category: "studentAssociation",
				name: "材料科學與工程學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/msenctu",
				img: nil,
				group: "https://www.facebook.com/groups/949067228547342/"
			},
			{
				category: "studentAssociation",
				name: "機械工程學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUME",
				img: nil,
				group:"https://www.facebook.com/groups/1717691548519926/"
			},
			{
				category: "studentAssociation",
				name: "土木工程學系",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			},
			{
				category: "studentAssociation",
				name: "電子物理學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTU.epstudentorganization",
				img: nil,
				group:"https://www.facebook.com/groups/1027416187344417/"
			},
			{
				category: "studentAssociation",
				name: "應用化學系",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			},
			{
				category: "studentAssociation",
				name: "應用數學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/nctuamsa04",
				img: nil,
				group: "https://www.facebook.com/groups/617667181721722/617669978388109/?ref=notif&notif_t=group_activity_unconfirmed&notif_id=1463481657931672&hc_location=ufi",
			},	
			{
				category: "studentAssociation",
				name: "資訊管理與財務金融學系",
				pdf: "資訊管理與財務金融學系-系學會新生通知.pdf",
				web: nil,
				fb: "https://www.facebook.com/NCTUIMF",
				img: nil
			},
			{
				category: "studentAssociation",
				name: "管理科學系",
				pdf: nil,
				web: "https://sites.google.com/a/ms.nctu.edu.tw/msstudent/home",
				fb: "https://www.facebook.com/NCTU.MS",
				img: nil,
				group: "https://www.facebook.com/groups/1725936697674250/"
			},
			{
				category: "studentAssociation",
				name: "運輸與物流管理學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUTLM",
				img: nil
			},
			{
				category: "studentAssociation",
				name: "外國語文學系",
				pdf: "外國語文學系-系學會新生通知.pdf",
				web: nil,
				fb: "https://www.facebook.com/NCTUFL",
				img: nil,
				group: "https://www.facebook.com/groups/1140809822609032/"
			},
			{
				category: "studentAssociation",
				name: "傳播與科技學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/CT.Associa",
				img: nil
			},
			{
				category: "studentAssociation",
				name: "人文社會學系",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/pages/%E4%BA%A4%E5%A4%A7%E4%BA%BA%E7%A4%BE%E7%B3%BB%E7%B3%BB%E5%AD%B8%E6%9C%83/370527856323364",
				img: nil,
				group:"https://www.facebook.com/groups/1594468117530437/"
			}
		]
	end



	def alumnian
		@title = "友會列表 ｜ 網路新生包"
		@data = [
			{
				category: "alumnian",
				name: "高雄屏東校友會(雄友會)",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/1793049137607116/ ",
				img: "雄友.jpg",
				color: "white"
			},
			{
				category: "alumnian",
				name: "竹苗地區校友會(竹友會)",
				pdf: "https://drive.google.com/file/d/0B1AOhZTA1x1NRTR6Wm0wc3RlYzA/view?pref=2&pli=1",
				web: nil,
				fb: "https://www.facebook.com/2012chuyo/",
				img: "竹友新生包.jpg",
				color: "white"
			},
			{
				category: "alumnian",
				name: "桃園地區友好會(桃友會)",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUTaoYoAssociation/?fref=ts",
				img: "桃友會.jpg",
				color: "default"
			},
			{
				category: "alumnian",
				name: "嘉義雲林校友會(雲嘉會)",
				pdf: nil,
				web: nil,
				group: "https://www.facebook.com/groups/606891969472726/",
				img: "雲嘉友會.jpg",
				color: "default"
			},
			{
				category: "alumnian",
				name: "台南地區校友會(南友會)",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTU.TN",
				img: nil,
				color: "default"
			},
			{
				category: "alumnian",
				name: "中部校友會(中友會)",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil,
			},
			{
				category: "alumnian",
				name: "建中北一女校友會(建北會)",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/pages/2015%E6%B8%85%E4%BA%A4%E5%BB%BA%E5%8C%97%E8%81%AF%E5%90%88%E8%BF%8E%E6%96%B0%E5%AE%BF%E7%87%9F/864703153565678",
				img: nil,
				color: "white"
			},
			{
				category: "alumnian",
				name: "北部校友會(北友會)",
				pdf: nil,
				web: nil,
				fb: "https://www.facebook.com/NCTUBYsummercamp.alwaysbewithyou",
				img: nil,
				color: "white"
			},
			{
				category: "alumnian",
				name: "武陵高中校友會(武友會)",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil,
				color: "white",
				group: "https://www.facebook.com/groups/981152421998748/"
			},
			{
				category: "alumnian",
				name: "宜蘭校友會(蘭友會)",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil,
				group: "https://www.facebook.com/groups/189918927715923/"
			},
			{
				category: "alumnian",
				name: "花蓮校友會",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			},
			{
				category: "alumnian",
				name: "澎湖校友會",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			},
			{
				category: "alumnian",
				name: "內湖高中校友會",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			},
			{
				category: "alumnian",
				name: "薇閣校友會",
				pdf: nil,
				web: nil,
				fb: nil,
				img: nil
			}
		]
	end



	def main
		@title = "首頁 | 網路新生包"
	end
	def procedure
		@title = "重要程序 | 網路新生包"
	end
	def qna
		@title = "精選問答 | 網路新生包"
	end
	def d2setup
		@title = "D2與宿網設置 | 網路新生包"
	end
	def chooseClass
		@title = "選課教學 | 網路新生包"
	end
	def map
		@title = "交大地圖 | 網路新生包"
	end
	def shopping
		@title = "新生團購 | 網路新生包"
	end
	def newtonA
		@title = "金牛頓學生特價 | 網路新生包"
	end
	def stunionIntro
		@title = "學聯會介紹 | 網路新生包"
	end
	def essentialShopping
		@title = "小七精美用品預購 | 網路新生包"
	end
end
