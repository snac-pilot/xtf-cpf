#!/usr/bin/env python
import csv
import sys
from xml.dom.minidom import Document

def main():
    """create the featured.html XML from tab delimited featured.txt"""
    tab2html("featured.txt", "featured.html")

def tab2html(input, output):
    tabfile = csv.reader(open(input, 'rb'), delimiter='\t')
    # start XML Document
    doc = Document()
    span = doc.createElement("span")
    h3 = doc.createElement("h3")
    h3.appendChild(doc.createTextNode("Featured Records"))
    span.appendChild(h3)
    for row in tabfile:
        if bool(row):
            div = doc.createElement("div")
            div.setAttribute('class', 'person')
            a = doc.createElement("a")
            a.setAttribute('href', "/xtf/view?docId=" + row[1])
            a.appendChild(doc.createTextNode(row[0]))
            div.appendChild(a)
            span.appendChild(div)
    doc.appendChild(span)
    print output
    f = open(output, 'w')
    doc.writexml(f, addindent="  ", newl="\n")
    f.close()

# <span>
#  <h3>Featured Records</h3>
#  <div class="person">
#    <a href="/xtf/view?docId=Slonimsky+Nicolas-cr.xml">
#      Slonimsky, Nicolas.
#    </a>
#  </div>
#</span>

# main() idiom for importing into REPL for debugging 
if __name__ == "__main__":
    sys.exit(main())
