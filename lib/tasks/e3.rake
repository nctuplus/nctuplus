namespace :e3 do
  desc "Get Material Info from e3"
  task GetMaterialInfo: :environment do
    require 'date'
    date = E3Service.getMaterialInfo[0]["TimeStart"]
    parsed = DateTime.parse(date).utc.to_i
    p date
    p Time.at(parsed).utc
  end
end
