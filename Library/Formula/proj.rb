require 'formula'

class Proj < Formula
  homepage 'http://trac.osgeo.org/proj/'
  url 'http://download.osgeo.org/proj/proj-4.8.0.tar.gz'
  sha1 '5c8d6769a791c390c873fef92134bf20bb20e82a'
  head 'http://svn.osgeo.org/metacrs/proj/trunk/proj/'

  option 'vdatum', 'Install vertical datum files'


  bottle do
    sha1 "08e30f4cf0b09f9f8d61e6ec73f025a8521039f4" => :mavericks
    sha1 "22bc868bb7198300724e837c2463b2f8cd31f942" => :mountain_lion
    sha1 "c25de74f90c56f3deff6ac1a0984fba265ececb2" => :lion
  end

  # The datum grid files are required to support datum shifting
  resource 'datumgrid' do
    url 'http://download.osgeo.org/proj/proj-datumgrid-1.5.zip'
    sha1 '4429ba1a8c764d5c0e6724d868f6874f452f7440'
  end

  resource 'usa_geoid2012' do
    url 'http://download.osgeo.org/proj/vdatum/usa_geoid2012.zip'
    sha1 '07359705877c2af2be3508e7905813f20ed4ba20'
  end

  resource 'usa_geoid2009' do
    url 'http://download.osgeo.org/proj/vdatum/usa_geoid2009.zip'
    sha1 '7ba5ff82dacf1dd56d666dd3ee8470e86946a479'
  end

  resource 'usa_geoid2003' do
    url 'http://download.osgeo.org/proj/vdatum/usa_geoid2003.zip'
    sha1 'd83c584c936045c9f6c51209e4726449eb5d1c17'
  end

  resource 'usa_geoid1999' do
    url 'http://download.osgeo.org/proj/vdatum/usa_geoid1999.zip'
    sha1 '1374f67dced7350783458431d916d1d8934cb187'
  end

  resource 'vertconc' do
    url 'http://download.osgeo.org/proj/vdatum/vertcon/vertconc.gtx'
    sha1 '9ce4b68f3991ed54316c0d534a3c5744b55b5cd2'
  end

  resource 'vertcone' do
    url 'http://download.osgeo.org/proj/vdatum/vertcon/vertcone.gtx'
    sha1 '265aa34c14ed049441c212aeda3cada9281e6ec7'
  end

  resource 'vertconw' do
    url 'http://download.osgeo.org/proj/vdatum/vertcon/vertconw.gtx'
    sha1 '379b4852b837ca4186f089f35d097521bf63ed1f'
  end    

  resource 'egm96_15' do
    url 'http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx'
    sha1 '5396c20a37c63abb1191ab44a164e2e2106dcb6c'
  end

  resource 'egm08_25' do
    url 'http://download.osgeo.org/proj/vdatum/egm08_25/egm08_25.gtx'
    sha1 'cddabcb9f9000afa869bdbfeb7bcf13521647fa7'
  end    
    
  skip_clean :la

  fails_with :llvm do
    build 2334
  end

  def install
    (buildpath/'nad').install resource('datumgrid')
    if build.include? 'vdatum'
      datums = ['usa_geoid2012', 'usa_geoid2009', 'usa_geoid2003', 'usa_geoid1999']
      datums += ['vertconc', 'vertcone', 'vertconw']
      datums += ['egm96_15', 'egm08_25']
      
      datums.each { |r|
        (share/'proj').install resource(r)
      }
      

    end
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
