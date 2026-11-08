# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

AccessCatalog.sync!

# Bu parolalar kayıt formundaki 12 karakter kuralından kısa; geliştirme hesapları olduğu için uzunluk doğrulaması atlanır.
[
  ["admin@eistatistik.com", "admin", "Kerem", "Murat"],
  ["musteri@eistatistik.com", "musteri", "Kerem", "Murat"],
  ["analizor@eistatistik.com", "analizor", "Naci", "Yılmaz"],
  ["asistan@eistatistik.com", "asistan", "eistatistik", "Asistan"],
  ["editor@eistatistik.com", "editor", "eistatistik", "Editör"]
].each do |email, role, first_name, last_name|
  account = User.find_or_initialize_by(email: email)
  account.password = "password123"
  account.password_confirmation = "password123"
  account.role = role
  account.skip_confirmation!
  account.skip_confirmation_notification!
  account.build_profile(first_name: first_name, last_name: last_name) unless account.profile
  account.save!(validate: false)
end
