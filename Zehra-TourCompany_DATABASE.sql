create database TurSirketi
use TurSirketi
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--TABLOLAR
create table Ulkeler
(
UlkeId nvarchar(5) primary key,
UlkeAd nvarchar(30) not null
)
create table Diller
(
DilId nvarchar(5) primary key,
DilAd nvarchar(30) not null
)
create table Mekanlar
(
MekanId int primary key identity(1,1),
MekanAd nvarchar(50) not null,
MekanUcretTl money not null,
MekanUcretUsd as (MekanUcretTl/18.82),
MekanUcretEur as (MekanUcretTl/20.37),
)
create table OdemeYontemi
(
YontemId int primary key identity(1,1),
YontemAd nvarchar(30) not null
)
create table OdemeParaCinsi
(
OdemeCinsId int primary key identity(1,1),
OdemeCinsAd nvarchar(30) not null
)
create table Rehberler
(
RehberId int primary key identity(1,1),
RehberAd nvarchar(50) not null,
RehberSoyad nvarchar(50) not null,
RehberCinsiyet nvarchar(10),
RehberTel nvarchar(15) not null,
RehberAdres nvarchar(200) default 'Bilinmiyor'
)
create table Turistler
(
TuristId int primary key identity(1,1),
TuristAd nvarchar(50) not null,
TuristSoyad nvarchar(50) not null,
TuristCinsiyet nvarchar(10),
TuristDT date not null,
TuristYas as Datediff(year,TuristDT,Getdate()),
TuristUlke nvarchar(5) foreign key references Ulkeler(UlkeId) not null,
TuristUyruk nvarchar(5) foreign key references Ulkeler(UlkeId) not null,
)
create table TuristDil
(
TuristId int foreign key references Turistler(TuristId),
DilId nvarchar(5) foreign key references Diller(DilId),
primary key(TuristId,DilId)
)
create table RehberDil
(
RehberId int foreign key references Rehberler(RehberId),
DilId nvarchar(5) foreign key references Diller(DilId),
primary key(RehberId,DilId)
)
create table Fatura
(
FaturaId int primary key identity(1,1),
RehberId int foreign key references Rehberler(RehberId) not null,
YontemId int foreign key references OdemeYontemi(YontemId) not null,
OdemeCinsId int foreign key references OdemeParaCinsi(OdemeCinsId) not null,
FaturaOdeyenId int foreign key references Turistler(TuristId) not null,
FaturaTarihi date not null
)
create table FaturaDetay--**BU TABLO MANUEL DEÐÝL FATURADETAYGIRIS PROCEDUR ÝLE DOLDURULACAKTIR**--
(
FaturaId int foreign key references Fatura(FaturaId),
TuristId int foreign key references Turistler(TuristId),
MekanId int foreign key references Mekanlar(MekanId),
TuristGelisTarih date,
MekanUcretTL money, 
MekanUcretUSD as (MekanUcretTL/18.82),
MekanUcretEUR as (MekanUcretTL/20.37),
KesilenBiletTur nvarchar(20),
KesilenBiletTL money,
KesilenBiletUSD as (KesilenBiletTL/18.82),
KesilenBiletEUR as (KesilenBiletTL/20.37),
primary key(FaturaId,TuristId,MekanId)
)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--FATURADETAYGIRIS PROCEDURE
create procedure FATURADETAYGIRIS(@faturaid int,@turistid int,@mekanid int,@gelistarih date)
as
if((select t.TuristYas from Turistler t where t.TuristId=@turistid)<10)
begin
declare @mekanucret money
set @mekanucret=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)
declare @tutar money
set @tutar=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)*(0.50)
insert into FaturaDetay(FaturaId,TuristId,MekanId,KesilenBiletTL,MekanUcretTL,TuristGelisTarih,KesilenBiletTur)
values(@faturaid,@turistid,@mekanid,@tutar,@mekanucret,@gelistarih,'Çocuk')
end
else if((select t.TuristYas from Turistler t where t.TuristId=@turistid) between 10 and 60)
begin
declare @mekanucret2 money
set @mekanucret2=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)
declare @tutar2 money
set @tutar2=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)
insert into FaturaDetay(FaturaId,TuristId,MekanId,KesilenBiletTL,MekanUcretTL,TuristGelisTarih,KesilenBiletTur)
values(@faturaid,@turistid,@mekanid,@tutar2,@mekanucret2,@gelistarih,'Tam')
end
else
begin
declare @mekanucret3 money
set @mekanucret3=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)
declare @tutar3 money
set @tutar3=(select m.MekanUcretTl from Mekanlar m where m.MekanId=@mekanid)*(0.75)
insert into FaturaDetay(FaturaId,TuristId,MekanId,KesilenBiletTL,MekanUcretTL,TuristGelisTarih,KesilenBiletTur)
values(@faturaid,@turistid,@mekanid,@tutar3,@mekanucret3,@gelistarih,'Yaþlý')
end
-----------------------------------------------------------------------------
--**FaturaToplamlarý view**--
create view FaturaToplamlarý
as
select fd.FaturaId,SUM(fd.KesilenBiletTL) as FaturaTutar from FaturaDetay fd group by fd.FaturaId
-----------------------------------------------------------------------------
--TABLOLARA VERÝ EKLEME
INSERT INTO Ulkeler(UlkeId,UlkeAd)
VALUES
('TR','Turkiye'),
('CN','China'),
('FR','France'),
('DE','Germany'),
('IT','Italy'),
('JP','Japan'),
('GB','England'),
('UA','Ukraine'),
('NL','Holland'),
('FI','Finland'),
('GR','Greece')
INSERT INTO Diller(DilId,DilAd)
VALUES
('TR','Turkish'),
('CN','Chinese'),
('FR','French'),
('DE','German'),
('IT','Italian'),
('JP','Japanese'),
('EN','English'),
('UA','Ukranian'),
('NL','Dutch'),
('FI','Finnish'),
('EL','Greek')
INSERT INTO Mekanlar(MekanAd,MekanUcretTl)
VALUES
('Ayasofya',100),
('Yerebatan Sarnýcý',150),
('Pierre Loti',125),
('Kýz kulesi',150),
('Adalar',100),
('Dolmabahçe Sarayý',125),
('Miniatürk',175),
('Sultan Ahmet Camii',150),
('Rumeli Hisarý',200),
('Mýsýr Çarþýsý',100),
('Anadolu Hisarý',125),
('Eyüp Sultan Camii',150),
('Atatürk Arboretumu',200),
('Kapalý çarþý',175)
INSERT INTO OdemeYontemi (YontemAd)
VALUES
('Nakit'),
('Kredi Kartý')
INSERT INTO OdemeParaCinsi(OdemeCinsAd)
VALUES
('TL'),
('USD'),
('EUR')
INSERT INTO Rehberler(RehberAd,RehberSoyad,RehberTel,RehberCinsiyet)
VALUES ('Ozan','Temiz','5556544343','Erkek')
INSERT INTO Rehberler(RehberAd,RehberSoyad,RehberTel,RehberCinsiyet,RehberAdres)
VALUES ('Bahar','Sevgin','5556544344','Kadýn','Kaðýthane')
INSERT INTO Rehberler(RehberAd,RehberSoyad,RehberTel,RehberCinsiyet,RehberAdres)
VALUES ('Omer','Ucar','5556544345','Erkek','Kurtköy')
INSERT INTO Rehberler(RehberAd,RehberSoyad,RehberTel,RehberCinsiyet,RehberAdres)
VALUES ('Sevgi','Cakmak','5556544346','Kadýn','Seyrantepe')
INSERT INTO Rehberler(RehberAd,RehberSoyad,RehberTel,RehberCinsiyet)
VALUES ('Linda','Callahan','5556544349','Kadýn')
INSERT INTO Turistler(TuristAd,TuristSoyad,TuristDT,TuristUyruk,TuristCinsiyet,TuristUlke)
VALUES 
('Levi', 'Acevedo', '06/11/1991', 'JP' ,'Kadýn','IT'),
('Basil', 'Aguilar', '04/22/1994', 'GR','Erkek','GR'),
( 'Zenaida', 'Holder', '01/09/1990', 'FI','Erkek','GR'),
( 'Illana', 'Browning', '01/28/1991', 'GR','Kadýn','GB'),
('Raja','Duke','07/27/1983','DE','Erkek','DE'),
('Isaiah','Valdez','01/16/1998','FI','Erkek','FI'),
('Gray','Marshall','11/21/1980','JP','Kadýn','JP'),
('Ora','Fletcher','01/19/1994','GB','Kadýn','GB'),
('Lavinia','Lloyd','10/26/1986','GB','Kadýn','GB'),
('Jenna','Williams','05/01/1982','GR','Kadýn','GR'),
('Christian','Nash','08/09/1980','GB','Erkek','GB'),
('Brianna','Everett','09/03/1978','JP','Erkek','JP'),
('Geoffrey','Knowles','02/17/1985','UA','Erkek','UA'),
('Quinn','Hamilton','07/10/1990','GB','Erkek','GB'),
('Kemal','Yetim','2018/12/26','TR','Erkek','TR'),
('Zehra','Boyan','1955/12/26','TR','Kadýn','TR')
INSERT INTO TuristDil(TuristId,DilId)
VALUES
(1,'JP'),
(1,'IT'),
(2,'EL'),
(3,'FI'),
(3,'EL'),
(4,'EL'),
(4,'EN'),
(5,'NL'),
(6,'FI'),
(7,'JP'),
(8,'EN'),
(9,'EN'),
(10,'EL'),
(11,'EN'),
(12,'JP'),
(13,'UA'),
(14,'EN'),
(15,'TR'),
(15,'EN'),
(16,'TR'),
(16,'JP')
INSERT INTO RehberDil(RehberId,DilId)
VALUES
(1,'JP'),
(1,'IT'),
(1,'FI'),
(1,'EN'),
(2,'EL'),
(2,'NL'),
(2,'EN'),
(2,'JP'),
(3,'FI'),
(3,'EL'),
(3,'EN'),
(4,'EN'),
(4,'EL'),
(5,'UA'),
(5,'JP')
insert into Fatura(RehberId,YontemId,OdemeCinsId,FaturaOdeyenId,FaturaTarihi)
values
(1,1,2,1,Getdate()),
(2,2,1,2,Getdate()),
(3,1,3,3,Getdate()),
(4,2,1,4,Getdate()),
(2,1,2,5,Getdate()),
(1,2,3,6,Getdate()),
(5,1,1,7,Getdate()),
(2,2,2,8,Getdate()),
(1,1,3,9,Getdate()),
(3,2,1,10,Getdate()),
(3,1,2,11,Getdate()),
(1,2,3,2,Getdate()),
(2,1,1,12,Getdate()),
(5,2,2,13,Getdate()),
(4,1,3,14,Getdate()),
(3,1,1,16,Getdate()),
(1,2,3,15,Getdate())
exec FATURADETAYGIRIS 1,1,1,'2012/01/11'
exec FATURADETAYGIRIS 1,1,2,'2012/01/11'
exec FATURADETAYGIRIS 2,2,3,'2014/11/08'
exec FATURADETAYGIRIS 2,2,4,'2014/11/08'
exec FATURADETAYGIRIS 3,3,5,'2014/04/02'
exec FATURADETAYGIRIS 3,3,1,'2014/04/02'
exec FATURADETAYGIRIS 3,3,6,'2014/04/02'
exec FATURADETAYGIRIS 4,4,7,'2014/01/05'
exec FATURADETAYGIRIS 4,4,8,'2014/01/05'
exec FATURADETAYGIRIS 5,5,9,'2014/08/09'
exec FATURADETAYGIRIS 6,6,6,'2012/08/28'
exec FATURADETAYGIRIS 6,6,10,'2012/08/28'
exec FATURADETAYGIRIS 7,7,9,'2013/08/27'
exec FATURADETAYGIRIS 7,7,4,'2013/08/27'
exec FATURADETAYGIRIS 8,8,11,'2014/08/23'
exec FATURADETAYGIRIS 8,8,12,'2014/08/23'
exec FATURADETAYGIRIS 9,9,3,'2012/03/26'
exec FATURADETAYGIRIS 9,9,4,'2012/03/26'
exec FATURADETAYGIRIS 10,10,13,'2014/11/26'
exec FATURADETAYGIRIS 10,10,6,'2014/11/26'
exec FATURADETAYGIRIS 11,11,14,'2013/02/15'
exec FATURADETAYGIRIS 11,11,10,'2013/02/15'
exec FATURADETAYGIRIS 12,2,13,'2014/09/09'
exec FATURADETAYGIRIS 13,12,3,'2013/04/19'
exec FATURADETAYGIRIS 13,12,4,'2013/04/19'
exec FATURADETAYGIRIS 14,13,10,'2014/01/26'
exec FATURADETAYGIRIS 14,13,13,'2014/01/26'
exec FATURADETAYGIRIS 15,14,4,'2013/04/12'
exec FATURADETAYGIRIS 15,14,7,'2013/04/12'
exec FATURADETAYGIRIS 16,16,5,'2013/04/12'
exec FATURADETAYGIRIS 16,16,8,'2013/04/12'
exec FATURADETAYGIRIS 17,15,3,'2013/04/12'
exec FATURADETAYGIRIS 17,15,9,'2013/04/12'