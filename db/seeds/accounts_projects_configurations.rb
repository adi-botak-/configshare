acc1 = Account.new(username: 'adi-botak-', email: 'adityautamawijaya@gmail.com')
acc1.password = 'mypassword'
acc1.save

proj1 = acc.add_owned_project(name: 'Adi Project')
proj1.repo_url = 'http://github.com/adi-botak-/project.git'
proj1.save
doc11 = proj1.add_configuration(filename: 'config_env.rb')
doc11.document = "this is the first line\nthis is the second line"
doc11.description = 'environmental configurations for test, development envs'
doc11.save
doc12 = proj1.add_configuration(filename: 'environments.ini')
doc12.document = '---'
doc12.save

proj2 = acc.add_owned_project(name: 'Config Project')
doc21 = proj2.add_configuration(filename: 'credentials.json')
doc21.document = 'username: password'
doc21.save

acc2 = Account.new(username: 'lee123', email: 'lee@nthu.edu.tw')
acc2.password = 'randompassword'
acc2.save