ActiveAdmin.register Maestrano::Connector::Rails::Synchronization do
  actions :all, :except => [:new]

  menu label: "Synchronizations", priority: 4

end
