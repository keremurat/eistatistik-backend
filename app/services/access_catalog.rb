class AccessCatalog
  PERMISSIONS = [
    { key: "menu.siparis", label: "Sipariş Menüsü", category: "menu" },
    { key: "menu.egitim", label: "Eğitim Menüsü", category: "menu" },
    { key: "menu.indirim", label: "İndirim Kodu Menüsü", category: "menu" },
    { key: "menu.kullanici", label: "Kullanıcı Menüsü", category: "menu" },
    { key: "menu.pano", label: "Pano Menüsü", category: "menu" },
    { key: "menu.duyuru", label: "Duyuru Menüsü", category: "menu" },
    { key: "menu.mesaj", label: "Mesaj Şablonları Menüsü", category: "menu" },
    { key: "menu.dashboard", label: "Dashboard Menüsü", category: "menu" },
    { key: "menu.takvim", label: "Takvim Menüsü", category: "menu" },
    { key: "menu.hizmet", label: "Hizmetler Menüsü", category: "menu" },
    { key: "menu.gorusme", label: "Görüşmeler Menüsü", category: "menu" },
    { key: "siparis.listele", label: "Sipariş Listele", category: "siparis" },
    { key: "siparis.goruntule", label: "Sipariş Görüntüle", category: "siparis" },
    { key: "siparis.olustur", label: "Sipariş Oluştur", category: "siparis" },
    { key: "siparis.sil", label: "Sipariş Sil", category: "siparis" },
    { key: "siparis.dashboard", label: "Sipariş Dashboard", category: "siparis" },
    { key: "siparis.analizor", label: "Analizör Atama", category: "siparis" },
    { key: "siparis.tum_yazisma", label: "Tüm Yazışmalar", category: "siparis" },
    { key: "siparis.eft", label: "EFT/Havale Kayıt", category: "siparis" },
    { key: "siparis.kredi", label: "Kredi Kartı İşlemi", category: "siparis" },
    { key: "siparis.iptal", label: "Sipariş İptal", category: "siparis" },
    { key: "siparis.teslim", label: "Teslim Et", category: "siparis" },
    { key: "egitim.listele", label: "Eğitim Listele", category: "egitim" },
    { key: "egitim.goruntule", label: "Eğitim Görüntüle", category: "egitim" },
    { key: "egitim.olustur", label: "Eğitim Oluştur", category: "egitim" },
    { key: "egitim.guncelle", label: "Eğitim Güncelle", category: "egitim" },
    { key: "egitim.sil", label: "Eğitim Sil", category: "egitim" },
    { key: "egitim.yonetim", label: "Eğitim Yönetim Düzenle", category: "egitim" },
    { key: "egitim.icerik", label: "Eğitim İçeriklerine Eriş", category: "egitim" },
    { key: "kupon.listele", label: "Kupon Listele", category: "kupon" },
    { key: "kupon.olustur", label: "Kupon Oluştur", category: "kupon" },
    { key: "kupon.goruntule", label: "Kupon Görüntüle", category: "kupon" },
    { key: "kupon.guncelle", label: "Kupon Güncelle", category: "kupon" },
    { key: "kupon.sil", label: "Kupon Sil", category: "kupon" },
    { key: "kupon.siparis_tanimla", label: "İndirim Kodu Tanımla (Sipariş)", category: "kupon" },
    { key: "kullanici.listele", label: "Kullanıcı Listele", category: "kullanici" },
    { key: "kullanici.goruntule", label: "Kullanıcı Görüntüle", category: "kullanici" },
    { key: "kullanici.duzenle", label: "Kullanıcı Düzenle", category: "kullanici" },
    { key: "kullanici.guncelle", label: "Kullanıcı Güncelle", category: "kullanici" },
    { key: "kullanici.sil", label: "Kullanıcı Sil", category: "kullanici" },
    { key: "kullanici.rapor", label: "Müşteri Raporları", category: "kullanici" },
    { key: "kullanici.whatsapp", label: "Toplu Mesaj (WhatsApp)", category: "kullanici" },
    { key: "pano.listele", label: "Pano Listele", category: "pano" },
    { key: "pano.olustur", label: "Pano Oluştur", category: "pano" },
    { key: "pano.duzenle", label: "Pano Düzenle", category: "pano" },
    { key: "pano.sil", label: "Pano Sil", category: "pano" },
    { key: "kart.olustur", label: "Kart Oluştur", category: "pano" },
    { key: "kart.duzenle", label: "Kart Düzenle", category: "pano" },
    { key: "kart.sil", label: "Kart Sil", category: "pano" },
    { key: "diger.duyuru", label: "Duyuru Yönetimi", category: "diger" },
    { key: "diger.mesaj", label: "Mesaj Şablonu Yönetimi", category: "diger" },
    { key: "diger.takvim", label: "Takvim Görüntüle", category: "diger" },
    { key: "diger.dashboard", label: "Dashboard Metrikleri", category: "diger" },
    { key: "diger.rol", label: "Rol Düzenleme", category: "diger" }
  ].freeze

  ANALIZOR = %w[
    menu.siparis menu.egitim menu.indirim menu.pano menu.dashboard menu.takvim menu.gorusme
    siparis.listele siparis.goruntule siparis.dashboard siparis.tum_yazisma
    siparis.analizor siparis.eft siparis.kredi siparis.teslim
    egitim.listele egitim.goruntule egitim.icerik
    kupon.siparis_tanimla
    pano.listele pano.olustur pano.duzenle kart.olustur kart.duzenle
    diger.takvim diger.dashboard
  ].freeze

  MUSTERI = %w[
    menu.siparis menu.egitim menu.dashboard menu.hizmet
    siparis.listele siparis.goruntule siparis.olustur siparis.eft siparis.kredi
    egitim.listele egitim.goruntule egitim.icerik
    diger.takvim
  ].freeze

  EDITOR = %w[
    menu.siparis menu.egitim menu.indirim menu.kullanici menu.pano menu.duyuru menu.mesaj menu.dashboard menu.takvim
    siparis.listele siparis.goruntule siparis.olustur siparis.dashboard siparis.tum_yazisma siparis.analizor siparis.eft siparis.kredi siparis.iptal siparis.teslim
    egitim.listele egitim.goruntule egitim.olustur egitim.guncelle egitim.sil egitim.yonetim egitim.icerik
    kupon.listele kupon.olustur kupon.goruntule kupon.guncelle kupon.sil kupon.siparis_tanimla
    kullanici.listele kullanici.goruntule kullanici.duzenle kullanici.guncelle kullanici.rapor
    pano.listele pano.olustur pano.duzenle kart.olustur kart.duzenle
    diger.duyuru diger.mesaj diger.takvim diger.dashboard
  ].freeze

  ASISTAN = %w[
    menu.siparis menu.egitim menu.indirim menu.kullanici menu.pano menu.duyuru menu.dashboard menu.takvim
    siparis.listele siparis.goruntule siparis.dashboard siparis.tum_yazisma siparis.analizor siparis.eft siparis.kredi siparis.iptal siparis.teslim
    egitim.listele egitim.goruntule egitim.olustur egitim.guncelle egitim.icerik
    kupon.listele kupon.goruntule kupon.siparis_tanimla
    kullanici.listele kullanici.goruntule kullanici.rapor kullanici.whatsapp
    pano.listele pano.olustur pano.duzenle kart.olustur kart.duzenle
    diger.duyuru diger.takvim diger.dashboard
  ].freeze

  ROLES = [
    { key: "admin", name: "Admin", description: "Tüm sistem yetkilerine sahip süper yönetici.", assignable: false, home_path: "/admin", permissions: :all },
    { key: "analizor", name: "Analizör", description: "Analiz ve sipariş süreçlerini yürüten analizör.", assignable: true, home_path: "/analizor", permissions: ANALIZOR },
    { key: "musteri", name: "Müşteri", description: "Sipariş verebilen ve eğitimlere erişen müşteri rolü.", assignable: false, home_path: "/dashboard", permissions: MUSTERI },
    { key: "editor", name: "Editör", description: "Geniş yetkili düzenleyici; rol yönetimi dışında tam.", assignable: false, home_path: "/editor", permissions: EDITOR },
    { key: "asistan", name: "Asistan", description: "Analizöre destek veren ve görev alabilen yardımcı.", assignable: true, home_path: "/asistan", permissions: ASISTAN }
  ].freeze

  def self.sync!
    permission_records = PERMISSIONS.map do |attrs|
      permission = Permission.find_or_initialize_by(key: attrs[:key])
      permission.update!(label: attrs[:label], category: attrs[:category])
      permission
    end
    known_keys = permission_records.map(&:key)

    ROLES.each do |attrs|
      role = Role.find_or_initialize_by(key: attrs[:key])
      fresh = role.new_record?
      role.update!(
        name: attrs[:name],
        description: attrs[:description],
        assignable: attrs[:assignable],
        system_role: true,
        home_path: attrs[:home_path]
      )
      next unless fresh

      keys = attrs[:permissions] == :all ? known_keys : attrs[:permissions]
      role.permissions = permission_records.select { |permission| keys.include?(permission.key) }
    end
  end
end
