all: doc

doc: doc_man doc_html

doc_html: html-stamp

html-stamp: grml2usb.8.txt grml2iso.8.txt
	asciidoc -b xhtml11 -a icons -a toc -a numbered grml2usb.8.txt
	asciidoc -b xhtml11 -a icons -a toc -a numbered grml2iso.8.txt
	touch html-stamp

doc_man: man-stamp

man-stamp: grml2usb.8.txt grml2iso.8.txt
	# grml2usb:
	asciidoc -d manpage -b docbook grml2usb.8.txt
	sed -i 's/<emphasis role="strong">/<emphasis role="bold">/' grml2usb.8.xml
	xsltproc --novalid --nonet /usr/share/xml/docbook/stylesheet/nwalsh/manpages/docbook.xsl grml2usb.8.xml
	# ugly hack to avoid duplicate empty lines in manpage
	# notice: docbook-xsl 1.71.0.dfsg.1-1 is broken! make sure you use 1.68.1.dfsg.1-0.2!
	cp grml2usb.8 grml2usb.8.tmp
	uniq grml2usb.8.tmp > grml2usb.8
	rm grml2usb.8.tmp
	# grml2iso:
	asciidoc -d manpage -b docbook grml2iso.8.txt
	sed -i 's/<emphasis role="strong">/<emphasis role="bold">/' grml2iso.8.xml
	xsltproc --novalid --nonet /usr/share/xml/docbook/stylesheet/nwalsh/manpages/docbook.xsl grml2iso.8.xml
	# ugly hack to avoid duplicate empty lines in manpage
	# notice: docbook-xsl 1.71.0.dfsg.1-1 is broken! make sure you use 1.68.1.dfsg.1-0.2!
	cp grml2iso.8 grml2iso.8.tmp
	uniq grml2iso.8.tmp > grml2iso.8
	rm grml2iso.8.tmp
	# we're done
	touch man-stamp

online: all
	scp grml2usb.8.html grml:/var/www/grml/grml2usb/index.html
	scp images/icons/*          grml:/var/www/grml/grml2usb/images/icons/
	scp images/screenshot.png   grml:/var/www/grml/grml2usb/images/

tarball: all
	./tarball.sh

prepare-release:
	./tarball.sh --no-gpg

clean:
	rm -rf grml2usb.8.html grml2usb.8.xml grml2usb.8
	rm -rf grml2iso.8.html grml2iso.8.xml grml2iso.8
	rm -rf html-stamp man-stamp grml2usb.tar.gz grml2usb.tgz grml2usb.tgz.md5.asc

codecheck:
	pyflakes grml2usb
	pylint --include-ids=y --max-line-length=120 grml2usb
	# pylint --include-ids=y --disable-msg-cat=C0301 --disable-msg-cat=W0511 grml2usb
	# pylint --reports=n --include-ids=y --disable-msg-cat=C0301 grml2usb
	pep8 --repeat --ignore E125,E126,E127,E128,E501 grml2usb

# graph:
#	sudo pycallgraph grml2usb /grml/isos/grml-small_2008.11.iso /dev/sdb1
