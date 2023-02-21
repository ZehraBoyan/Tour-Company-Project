--1-Rehberlerimin bu zamana kadar ilgilendikleri tüm turistleri ülke ve uyruk bilgileri ile getiriniz.
select distinct r.RehberAd+' '+r.RehberSoyad as Rehber,t.TuristAd+' '+t.TuristSoyad as Turist,t.TuristUlke,t.TuristUyruk from Fatura f 
join FaturaDetay fd on f.FaturaId=fd.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Rehberler r on r.RehberId=f.RehberId

--2-Her bir tur için indirimli, tam, yarým fiyatýný listeleyen sorguyu yazýn. Zam veya indirim uygulanmýþ turlarýn da geçmiþe yönelik tüm fiyat bilgisi gelsin.
--Rapor þu þekilde olmalý;
--Ayasofya | Tam | 120 | 2015-05-05
--Ayasofya | Yarým | 60 | 2015-05-05   ....vb
select m.MekanAd,fd.KesilenBiletTur,fd.KesilenBiletTL,f.FaturaTarihi from FaturaDetay fd
join Mekanlar m on m.MekanId=fd.MekanId
join Fatura f on f.FaturaId=fd.FaturaId
order by 1

--3-þu zamana kadar yapýlan en pahalý tura hangi turistim dahil olmuþ, bu turun ödemesini kim yapmýþ ve bu turiste hangi tur rehberi atanmýþ? Ayný fiyat bilgisine sahip diðer kayýtlar da gelsin.***
-----------------------------------------------------------
--**(Bu soruda FaturaToplamlarý isimli view kullanýldý)**--
-----------------------------------------------------------
select fd.FaturaId,t.TuristAd+' '+t.TuristSoyad as Turist,t1.TuristAd+' '+t1.TuristSoyad as [Ödeyen Turist],r.RehberAd+' '+r.RehberSoyad as Rehber,
(SUM(fd.KesilenBiletTL)) as [Fatura Tutarý] from 
FaturaDetay fd
join Fatura f on f.FaturaId=fd.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Turistler t1 on t1.TuristId=f.FaturaOdeyenId
join Rehberler r on r.RehberId=f.RehberId
group by fd.FaturaId,t.TuristAd,t.TuristSoyad,fd.TuristId,r.RehberAd,r.RehberSoyad,t1.TuristAd,t1.TuristSoyad
having fd.FaturaId=(select ft.FaturaId from FaturaToplamlarý ft where ft.FaturaTutar=(select MAX(ft1.FaturaTutar) from FaturaToplamlarý ft1))


--4-Almanya uyruklu turistlerimden tam bilet ile tura katýlan turistlerim nereleri hangi tur rehberi ile ziyaret etmiþ.
select t.TuristAd+' '+t.TuristSoyad as Turist,u.UlkeAd,m.MekanAd,r.RehberAd+' '+r.RehberSoyad as Rehber,fd.KesilenBiletTur,fd.KesilenBiletTL
from FaturaDetay fd
join Turistler t on t.TuristId=fd.TuristId
join Mekanlar m on m.MekanId=fd.MekanId
join Fatura f on f.FaturaId=fd.FaturaId
join Rehberler r on r.RehberId=f.RehberId
join Ulkeler u on u.UlkeId=t.TuristUyruk
where fd.KesilenBiletTur='Tam' and t.TuristUyruk='DE'

--5-ýngilizce bildiði halde ülkesi de uyruðu da ýngiltere olmayan turistlere rehberlik eden tur rehberlerim kimler? ýlgilendiði turist bilgileri ile beraber raporlansýn.
select distinct t.TuristAd,u.UlkeAd Ulke,u1.UlkeAd Uyruk,d.DilAd,r.RehberAd+' '+r.RehberSoyad as Rehber from TuristDil td
join Turistler t on t.TuristId=td.TuristId
join Diller d on d.DilId=td.DilId
join Ulkeler u on u.UlkeId=t.TuristUlke
join Ulkeler u1 on u1.UlkeId=t.TuristUyruk
join FaturaDetay fd on fd.TuristId=t.TuristId
join Fatura f on f.FaturaId=fd.FaturaId
join Rehberler r on r.RehberId=f.RehberId
where d.DilAd like '%eng%' and u.UlkeAd!='England' and u1.UlkeAd!='England'

--6-Listemde olduðu halde rehberlerimin bildiði diller arasýnda yer almayan diller hangileridir?
select * from RehberDil rd right join Diller d on rd.DilId=d.DilId
where rd.DilId is null

--7-Ülkesi Japonya olan müþterilerim fatura ödemelerini hangi para biriminde yapmýþlar. (Turist Ad, Soyad, Ülke, FaturaTarihi, Ödemeþekli, ParaBirimi)
select distinct t.TuristAd,t.TuristSoyad,u.UlkeAd,f.FaturaTarihi,oy.YontemAd,op.OdemeCinsAd from Fatura f
join FaturaDetay fd on fd.FaturaId=f.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Ulkeler u on u.UlkeId=t.TuristUlke
join OdemeParaCinsi op on op.OdemeCinsId=f.OdemeCinsId
join OdemeYontemi oy on oy.YontemId=f.YontemId
where u.UlkeAd='Japan'

--8-Nakit ödeme yapmamayý tercih eden müþterilerim hangi ülkelerden (Sorguyu diðer ödeme þekil(ler)ini bilmiyormuþ gibi yazýnýz)
select distinct t.TuristAd,t.TuristSoyad,u.UlkeAd,oy.YontemAd from Fatura f
join FaturaDetay fd on fd.FaturaId=f.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Ulkeler u on u.UlkeId=t.TuristUlke
join OdemeParaCinsi op on op.OdemeCinsId=f.OdemeCinsId
join OdemeYontemi oy on oy.YontemId=f.YontemId
where oy.YontemAd!='Nakit'