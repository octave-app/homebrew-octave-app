class Buildbot < Formula
  include Language::Python::Virtualenv

  desc "CI framework with batteries included"
  homepage "http://buildbot.net/"
  url "https://files.pythonhosted.org/packages/a5/5c/ba8ef10900ee639bdcd69c405b3dc22ba8e061b729eb955139153710e2fc/buildbot-1.8.0.tar.gz"
  sha256 "0ae0cd305eaf3e0c0655e1bd2aac58a258718da34c0d1afc27d465dd55a812ec"

  depends_on "python3"

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/0f/9e/26b1d194aab960063b266170e53c39f73ea0d0d3f5ce23313e0ec8ee9bdf/attrs-18.2.0.tar.gz"
    sha256 "10cbf6e27dbce8c30807caf056c8eb50917e0eaafe86347671b57254006c3e69"
  end

  resource "autobahn" do
    url "https://files.pythonhosted.org/packages/66/cc/1e2b20dc6654d9a87fc30da36bfae687ec65428814378c44257a26fe5f2f/autobahn-19.1.1.tar.gz"
    sha256 "aebbadb700c13792a2967c79002855d1153b9ec8f2949d169e908388699596ff"
  end

  resource "Automat" do
    url "https://files.pythonhosted.org/packages/4a/4f/64db3ffda8828cb0541fe949354615f39d02f596b4c33fb74863756fc565/Automat-0.7.0.tar.gz"
    sha256 "cbd78b83fa2d81fe2a4d23d258e1661dd7493c9a50ee2f1a5b2cac61c1793b0e"
  end

  resource "buildbot" do
    url "https://files.pythonhosted.org/packages/a5/5c/ba8ef10900ee639bdcd69c405b3dc22ba8e061b729eb955139153710e2fc/buildbot-1.8.0.tar.gz"
    sha256 "0ae0cd305eaf3e0c0655e1bd2aac58a258718da34c0d1afc27d465dd55a812ec"
  end

  resource "buildbot-pkg" do
    url "https://files.pythonhosted.org/packages/39/5c/68d4b93b7baf308d4220c52a1791a0b27a3c72af82a431278319b056dd6d/buildbot-pkg-1.8.0.tar.gz"
    sha256 "d2993713b4407152a7ebd6c34090091be8c36e8d0e68617cb09173c57a1ff067"
  end

  resource "buildbot-console-view" do
    url "https://files.pythonhosted.org/packages/98/bf/470a4497d8cc0ea8ff4ed1f6e8e172871adbac85f10ec623006ea844918b/buildbot-console-view-1.8.0.tar.gz"
    sha256 "4f21ac00c11de853cffcc48d55408bd55896f0d54fc41e001ed3784ba1e3a98c"
  end

  resource "buildbot-grid-view" do
    url "https://files.pythonhosted.org/packages/b8/64/c70a215c58a158f25f60f56b43e9d273865d8442f7b91352cfedfdd96121/buildbot-grid-view-1.8.0.tar.gz"
    sha256 "56db59de092750e66fba732c1fe5426a04b9b132fed41de422695f9fb511bbb1"
  end

  resource "buildbot-waterfall-view" do
    url "https://files.pythonhosted.org/packages/b4/89/674bda2d8400de363341077da7c4eea61437d0034843d731cecd0417ad24/buildbot-waterfall-view-1.8.0.tar.gz"
    sha256 "9d0da51c70cdba6478559b9bd042a23c6f5ef1b05dc2b02066576379f325cb1d"
  end

  resource "buildbot-worker" do
    url "https://files.pythonhosted.org/packages/a7/ec/0c9815394fa7649552901a6075430511a16c022479c93e88189a406a7abc/buildbot-worker-1.8.0.tar.gz"
    sha256 "83b148cf165db1125599c72fa1822f59e84d390f705a4c7499d332026eacfcb5"
  end

  resource "mock" do
    url "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"
    sha256 "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/33/07/6e68a96ff240a0e7bb1f6e21093532386a98a82d56512e1e3da6d125f7aa/pbr-5.1.1.tar.gz"
    sha256 "f59d71442f9ece3dffc17bc36575768e1ee9967756e6b6535f0ee1f0054c3d68"
  end

  resource "buildbot-www" do
    url "https://files.pythonhosted.org/packages/50/f4/c657a59b87fcaffef547814dd7b303c11d0fdeb0e4b47c44a0cbdad65a57/buildbot-www-1.8.0.tar.gz"
    sha256 "629e21fb3d024e7a8049a1e8e14cacce200724e6196975debdf88a2d777fe899"
  end

  resource "constantly" do
    url "https://files.pythonhosted.org/packages/95/f1/207a0a478c4bb34b1b49d5915e2db574cadc415c9ac3a7ef17e29b2e8951/constantly-15.1.0.tar.gz"
    sha256 "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35"
  end

  resource "decorator" do
    url "https://files.pythonhosted.org/packages/6f/24/15a229626c775aae5806312f6bf1e2a73785be3402c0acdec5dbddd8c11e/decorator-4.3.0.tar.gz"
    sha256 "c39efa13fbdeb4506c476c9b3babf6a718da943dab7811c206005a4a956c080c"
  end

  resource "future" do
    url "https://files.pythonhosted.org/packages/90/52/e20466b85000a181e1e144fd8305caf2cf475e2f9674e797b222f8105f5f/future-0.17.1.tar.gz"
    sha256 "67045236dcfd6816dc439556d009594abf643e5eb48992e36beac09c2ca659b8"
  end

  resource "hyperlink" do
    url "https://files.pythonhosted.org/packages/41/e1/0abd4b480ec04892b1db714560f8c855d43df81895c98506442babf3652f/hyperlink-18.0.0.tar.gz"
    sha256 "f01b4ff744f14bc5d0a22a6b9f1525ab7d6312cb0ff967f59414bbac52f0a306"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"
    sha256 "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"
  end

  resource "incremental" do
    url "https://files.pythonhosted.org/packages/8f/26/02c4016aa95f45479eea37c90c34f8fab6775732ae62587a874b619ca097/incremental-17.5.0.tar.gz"
    sha256 "7b751696aaf36eebfab537e458929e194460051ccad279c72b755a167eebd4b3"
  end

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"
    sha256 "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/ac/7e/1b4c2e05809a4414ebce0892fe1e32c14ace86ca7d50c70f00979ca9b3a3/MarkupSafe-1.1.0.tar.gz"
    sha256 "4e97332c9ce444b0c2c38dd22ddc61c743eb208d916e4265a2a3b575bdccb1d3"
  end

  resource "PyHamcrest" do
    url "https://files.pythonhosted.org/packages/a4/89/a469aad9256aedfbb47a29ec2b2eeb855d9f24a7a4c2ff28bd8d1042ef02/PyHamcrest-1.9.0.tar.gz"
    sha256 "8ffaa0a53da57e89de14ced7185ac746227a8894dbd5a3c718bf05ddbd1d56cd"
  end

  resource "PyJWT" do
    url "https://files.pythonhosted.org/packages/2f/38/ff37a24c0243c5f45f5798bd120c0f873eeed073994133c084e1cf13b95c/PyJWT-1.7.1.tar.gz"
    sha256 "8d59a976fb773f3e6a39c85636357c4f0e242707394cadadd9814f5cbaa20e96"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
    sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  resource "SQLAlchemy" do
    url "https://files.pythonhosted.org/packages/05/d2/17fb194f4ae83577258ea1d81da3d5d5643f4957fa14fd0261d78d648bf5/SQLAlchemy-1.2.16.tar.gz"
    sha256 "6af3ca2f7f00844465ab4fa78337d487b39e53f516c51328aed4ed3a719d4264"
  end

  resource "sqlalchemy-migrate" do
    url "https://files.pythonhosted.org/packages/05/18/6d339bd6222f7a7613638fafc9ff4c4f0e312843d359e85489dc07b21df5/sqlalchemy-migrate-0.11.0.tar.gz"
    sha256 "e68af5e3e0561f629d4eb23d9d0ea77d2649747f2eff37fd29aece74615ca251"
  end

  resource "sqlparse" do
    url "https://files.pythonhosted.org/packages/79/3c/2ad76ba49f9e3d88d2b58e135b7821d93741856d1fe49970171f73529303/sqlparse-0.2.4.tar.gz"
    sha256 "ce028444cfab83be538752a2ffdb56bc417b7784ff35bb9a3062413717807dec"
  end

  resource "Tempita" do
    url "https://files.pythonhosted.org/packages/56/c8/8ed6eee83dbddf7b0fc64dd5d4454bc05e6ccaafff47991f73f2894d9ff4/Tempita-0.5.2.tar.gz"
    sha256 "cacecf0baa674d356641f1d406b8bff1d756d739c46b869a54de515d08e6fc9c"
  end

  resource "Twisted" do
    url "https://files.pythonhosted.org/packages/5d/0e/a72d85a55761c2c3ff1cb968143a2fd5f360220779ed90e0fadf4106d4f2/Twisted-18.9.0.tar.bz2"
    sha256 "294be2c6bf84ae776df2fc98e7af7d6537e1c5e60a46d33c3ce2a197677da395"
  end

  resource "txaio" do
    url "https://files.pythonhosted.org/packages/c1/99/81de004578e9afe017bb1d4c8968088a33621c05449fe330bdd7016d5377/txaio-18.8.1.tar.gz"
    sha256 "67e360ac73b12c52058219bb5f8b3ed4105d2636707a36a7cdafb56fe06db7fe"
  end

  resource "zope.interface" do
    url "https://files.pythonhosted.org/packages/4e/d0/c9d16bd5b38de44a20c6dc5d5ed80a49626fafcb3db9f9efdc2a19026db6/zope.interface-4.6.0.tar.gz"
    sha256 "1b3d0dcabc7c90b470e59e38a9acaa361be43b3a6ea644c0063951964717f0e5"
  end

  def install
    virtualenv_create(libexec, "python3")
    virtualenv_install_with_resources
  end

  test do
    assert_match "Buildbot", shell_output("#{bin}/buildbot --version")
  end
end
