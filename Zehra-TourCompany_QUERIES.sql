--1-Rehberlerimin bu zamana kadar ilgilendikleri t�m turistleri �lke ve uyruk bilgileri ile getiriniz.
select distinct r.RehberAd+' '+r.RehberSoyad as Rehber,t.TuristAd+' '+t.TuristSoyad as Turist,t.TuristUlke,t.TuristUyruk from Fatura f 
join FaturaDetay fd on f.FaturaId=fd.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Rehberler r on r.RehberId=f.RehberId

--2-Her bir tur i�in indirimli, tam, yar�m fiyat�n� listeleyen sorguyu yaz�n. Zam veya indirim uygulanm�� turlar�n da ge�mi�e y�nelik t�m fiyat bilgisi gelsin.
--Rapor �u �ekilde olmal�;
--Ayasofya | Tam | 120 | 2015-05-05
--Ayasofya | Yar�m | 60 | 2015-05-05   ....vb
select m.MekanAd,fd.KesilenBiletTur,fd.KesilenBiletTL,f.FaturaTarihi from FaturaDetay fd
join Mekanlar m on m.MekanId=fd.MekanId
join Fatura f on f.FaturaId=fd.FaturaId
order by 1

--3-�u zamana kadar yap�lan en pahal� tura hangi turistim dahil olmu�, bu turun �demesini kim yapm�� ve bu turiste hangi tur rehberi atanm��? Ayn� fiyat bilgisine sahip di�er kay�tlar da gelsin.***
-----------------------------------------------------------
--**(Bu soruda FaturaToplamlar� isimli view kullan�ld�)**--
-----------------------------------------------------------
select fd.FaturaId,t.TuristAd+' '+t.TuristSoyad as Turist,t1.TuristAd+' '+t1.TuristSoyad as [�deyen Turist],r.RehberAd+' '+r.RehberSoyad as Rehber,
(SUM(fd.KesilenBiletTL)) as [Fatura Tutar�] from 
FaturaDetay fd
join Fatura f on f.FaturaId=fd.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Turistler t1 on t1.TuristId=f.FaturaOdeyenId
join Rehberler r on r.RehberId=f.RehberId
group by fd.FaturaId,t.TuristAd,t.TuristSoyad,fd.TuristId,r.RehberAd,r.RehberSoyad,t1.TuristAd,t1.TuristSoyad
having fd.FaturaId=(select ft.FaturaId from FaturaToplamlar� ft where ft.FaturaTutar=(select MAX(ft1.FaturaTutar) from FaturaToplamlar� ft1))


--4-Almanya uyruklu turistlerimden tam bilet ile tura kat�lan turistlerim nereleri hangi tur rehberi ile ziyaret etmi�.
select t.TuristAd+' '+t.TuristSoyad as Turist,u.UlkeAd,m.MekanAd,r.RehberAd+' '+r.RehberSoyad as Rehber,fd.KesilenBiletTur,fd.KesilenBiletTL
from FaturaDetay fd
join Turistler t on t.TuristId=fd.TuristId
join Mekanlar m on m.MekanId=fd.MekanId
join Fatura f on f.FaturaId=fd.FaturaId
join Rehberler r on r.RehberId=f.RehberId
join Ulkeler u on u.UlkeId=t.TuristUyruk
where fd.KesilenBiletTur='Tam' and t.TuristUyruk='DE'

--5-�ngilizce bildi�i halde �lkesi de uyru�u da �ngiltere olmayan turistlere rehberlik eden tur rehberlerim kimler? �lgilendi�i turist bilgileri ile beraber raporlans�n.
select distinct t.TuristAd,u.UlkeAd Ulke,u1.UlkeAd Uyruk,d.DilAd,r.RehberAd+' '+r.RehberSoyad as Rehber from TuristDil td
join Turistler t on t.TuristId=td.TuristId
join Diller d on d.DilId=td.DilId
join Ulkeler u on u.UlkeId=t.TuristUlke
join Ulkeler u1 on u1.UlkeId=t.TuristUyruk
join FaturaDetay fd on fd.TuristId=t.TuristId
join Fatura f on f.FaturaId=fd.FaturaId
join Rehberler r on r.RehberId=f.RehberId
where d.DilAd like '%eng%' and u.UlkeAd!='England' and u1.UlkeAd!='England'

--6-Listemde oldu�u halde rehberlerimin bildi�i diller aras�nda yer almayan diller hangileridir?
select * from RehberDil rd right join Diller d on rd.DilId=d.DilId
where rd.DilId is null

--7-�lkesi Japonya olan m��terilerim fatura �demelerini hangi para biriminde yapm��lar. (Turist Ad, Soyad, �lke, FaturaTarihi, �deme�ekli, ParaBirimi)
select distinct t.TuristAd,t.TuristSoyad,u.UlkeAd,f.FaturaTarihi,oy.YontemAd,op.OdemeCinsAd from Fatura f
join FaturaDetay fd on fd.FaturaId=f.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Ulkeler u on u.UlkeId=t.TuristUlke
join OdemeParaCinsi op on op.OdemeCinsId=f.OdemeCinsId
join OdemeYontemi oy on oy.YontemId=f.YontemId
where u.UlkeAd='Japan'

--8-Nakit �deme yapmamay� tercih eden m��terilerim hangi �lkelerden (Sorguyu di�er �deme �ekil(ler)ini bilmiyormu� gibi yaz�n�z)
select distinct t.TuristAd,t.TuristSoyad,u.UlkeAd,oy.YontemAd from Fatura f
join FaturaDetay fd on fd.FaturaId=f.FaturaId
join Turistler t on t.TuristId=fd.TuristId
join Ulkeler u on u.UlkeId=t.TuristUlke
join OdemeParaCinsi op on op.OdemeCinsId=f.OdemeCinsId
join OdemeYontemi oy on oy.YontemId=f.YontemId
where oy.YontemAd!='Nakit'