namespace :employees do
  desc "Change status"
  task set_status_default: :environment do
    employees = Employee.where(status: nil)
    puts "Going to update #{employees.count} events"

    ActiveRecord::Base.transaction do
      employees.each do |employee|
        employee.status = "draft"
        employee.save!
        print "."
      end
    end

    puts " All done now!"
  end
end