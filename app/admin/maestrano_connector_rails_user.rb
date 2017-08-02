ActiveAdmin.register Maestrano::Connector::Rails::User do
  actions :all, :except => [:new]

  menu label: "Users", priority: 2

end
