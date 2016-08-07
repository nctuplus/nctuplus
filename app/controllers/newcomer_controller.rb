class NewcomerController < ApplicationController
	def curricular
		@title = "社團資訊 | 網路新生包"
		@data = NewcomerClub.where(:category => "curricular")
	end
	def studentAssociation
		@title = "系學會 | 網路新生包"
		@data = NewcomerClub.where(:category => "studentAssociation")
	end
	def alumnian
		@title = "友會列表 ｜ 網路新生包"   
		@data = NewcomerClub.where(:category => "alumnian")
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
end
