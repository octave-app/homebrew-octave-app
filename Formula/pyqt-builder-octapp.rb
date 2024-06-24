# pyqt-builder, octapp-hacked variant
#
# Octapp hacks:
#  * Install to python@3.11 in addition to python@3.12, since we're stuck on python@3.11
#    for some stuff like qt5 and thus qscintilla2-qt5, and those need python@3.11. This
#    uses the old 'pip install' approach from the core pyqt-builder 1.15 formula, because
#    I can't figure out how to get the new Virtualenv installation approach to work with
#    multiple pythons.
class PyqtBuilderOctapp < Formula
  include Language::Python::Virtualenv

  desc "Tool to build PyQt"
  homepage "https://www.riverbankcomputing.com/software/pyqt-builder/intro"
  url "https://files.pythonhosted.org/packages/57/09/11d09b4140932960a4e232e04858ceda19d821f8deb350605934f2251c87/pyqt_builder-1.16.2.tar.gz"
  sha256 "bf723cdb7cd23d2512e2acda7bc6b81f00fb05ccc5e9a8846bd34d47514cddb9"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  head "https://www.riverbankcomputing.com/hg/PyQt-builder", using: :hg

  depends_on "python@3.11"
  depends_on "python@3.12"
  depends_on "sip"

  conflicts_with "pyqt-builder", because: "both install pyqt-builder binaries"

  def pythons
    ["python3.11", "python3.12"]
  end

  def install
    pythons.each do |python3|
      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    system bin/"pyqt-bundle", "-V"
    system libexec/"bin/python", "-c", "import pyqtbuild"
  end
end
