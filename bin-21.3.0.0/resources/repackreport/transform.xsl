<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="UTF-8"/>

  <xsl:template match="/">
    <html>
      <head>
        <style>
         * {
  -webkit-print-color-adjust: exact;
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
}
*:before,
*:after {
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
}

body {
max-width:1100px;
margin: 0 auto;
font-family: 'Segoe UI', Arial, Helvetica, serif;
color: #333;
}

/* Tables */
.table {
border-collapse: collapse;
font-family:Consolas,monospace;
}

.table-bordered td,.table-bordered th {
border: 1px solid #E4E4E6!important
}

caption {
padding-top: 8px;
padding-bottom: 8px;
color: #777;
text-align: left;
}

th {
text-align: left;
}

.table {
width: 100%;
max-width: 100%;
margin-bottom: 20px;
}

.table tr {
    page-break-inside: avoid;
}

.table>tbody>tr>td,.table>tbody>tr>th,.table>tfoot>tr>td,.table>tfoot>tr>th,.table>thead>tr>td,.table>thead>tr>th {
padding: 8px;
line-height: 1.42857143;
vertical-align: top;
border-top: 1px solid #E4E4E6;
}

.table>thead>tr>th {
vertical-align: bottom;
border-bottom: 2px solid #E4E4E6;
}

.table>caption+thead>tr:first-child>td,.table>caption+thead>tr:first-child>th,.table>colgroup+thead>tr:first-child>td,.table>colgroup+thead>tr:first-child>th,.table>thead:first-child>tr:first-child>td,.table>thead:first-child>tr:first-child>th {
border-top: 0;
}

.table>tbody+tbody {
border-top: 2px solid #E4E4E6;
}

.table .table {
background-color: #fff;
}

.table-condensed>tbody>tr>td,.table-condensed>tbody>tr>th,.table-condensed>tfoot>tr>td,.table-condensed>tfoot>tr>th,.table-condensed>thead>tr>td,.table-condensed>thead>tr>th {
padding: 5px;
}

.table-bordered {
border: 1px solid #E4E4E6;
}

.table-bordered>tbody>tr>td,.table-bordered>tbody>tr>th,.table-bordered>tfoot>tr>td,.table-bordered>tfoot>tr>th,.table-bordered>thead>tr>td,.table-bordered>thead>tr>th {
border: 1px solid #E4E4E6;
}

.table-bordered>thead>tr>td,.table-bordered>thead>tr>th {
border-bottom-width: 2px;
}

.table-striped>tbody>tr:nth-of-type(odd) {
background-color: #F7F7FA; /*f9f9f9*/
}

.table-hover>tbody>tr:hover {
background-color: #f5f5f5;
}

/* Typography */
.h1,.h2,.h3,.h4,.h5,.h6,h1,h2,h3,h4,h5,h6 {
font-family: inherit;
font-weight: 500;
line-height: 1.1;
color: inherit;
}

h1,h2,h3 {
margin-top: 20px;
margin-bottom: 10px
}

.h1 .small,.h1 small,.h2 .small,.h2 small,.h3 .small,.h3 small,h1 .small,h1 small,h2 .small,h2 small,h3 .small,h3 small {
font-size: 65%
}

h4,h5,h6 {
margin-top: 10px;
margin-bottom: 10px
}

.h4 .small,.h4 small,.h5 .small,.h5 small,.h6 .small,.h6 small,h4 .small,h4 small,h5 .small,h5 small,h6 .small,h6 small {
font-size: 75%
}

.h1,h1 {
font-size: 36px
}

.h2,h2 {
font-size: 30px
}

.h3,h3 {
font-size: 20px;
text-transform: uppercase;
font-weight: bold;
opacity: 0.7;
}

.h4,h4 {
font-size: 18px
}

.h5,h5 {
font-size: 14px
}

.h6,h6 {
font-size: 12px
}


/* Grid */
.row {
  margin-left: -15px;
  margin-right: -15px;
}
.col-xs-1, .col-sm-1, .col-md-1, .col-lg-1, .col-xs-2, .col-sm-2, .col-md-2, .col-lg-2, .col-xs-3, .col-sm-3, .col-md-3, .col-lg-3, .col-xs-4, .col-sm-4, .col-md-4, .col-lg-4, .col-xs-5, .col-sm-5, .col-md-5, .col-lg-5, .col-xs-6, .col-sm-6, .col-md-6, .col-lg-6, .col-xs-7, .col-sm-7, .col-md-7, .col-lg-7, .col-xs-8, .col-sm-8, .col-md-8, .col-lg-8, .col-xs-9, .col-sm-9, .col-md-9, .col-lg-9, .col-xs-10, .col-sm-10, .col-md-10, .col-lg-10, .col-xs-11, .col-sm-11, .col-md-11, .col-lg-11, .col-xs-12, .col-sm-12, .col-md-12, .col-lg-12 {
  position: relative;
  min-height: 1px;
  padding-left: 15px;
  padding-right: 15px;
  page-break-inside: avoid !important;
}
.col-xs-1, .col-xs-2, .col-xs-3, .col-xs-4, .col-xs-5, .col-xs-6, .col-xs-7, .col-xs-8, .col-xs-9, .col-xs-10, .col-xs-11, .col-xs-12 {
  float: left;
}
.col-xs-12 {
  width: 100%;
}
.col-xs-11 {
  width: 91.66666667%;
}
.col-xs-10 {
  width: 83.33333333%;
}
.col-xs-9 {
  width: 75%;
}
.col-xs-8 {
  width: 66.66666667%;
}
.col-xs-7 {
  width: 58.33333333%;
}
.col-xs-6 {
  width: 50%;
}
.col-xs-5 {
  width: 41.66666667%;
}
.col-xs-4 {
  width: 33.33333333%;
}
.col-xs-3 {
  width: 25%;
}
.col-xs-2 {
  width: 16.66666667%;
}
.col-xs-1 {
  width: 8.33333333%;
}
.col-xs-pull-12 {
  right: 100%;
}
.col-xs-pull-11 {
  right: 91.66666667%;
}
.col-xs-pull-10 {
  right: 83.33333333%;
}
.col-xs-pull-9 {
  right: 75%;
}
.col-xs-pull-8 {
  right: 66.66666667%;
}
.col-xs-pull-7 {
  right: 58.33333333%;
}
.col-xs-pull-6 {
  right: 50%;
}
.col-xs-pull-5 {
  right: 41.66666667%;
}
.col-xs-pull-4 {
  right: 33.33333333%;
}
.col-xs-pull-3 {
  right: 25%;
}
.col-xs-pull-2 {
  right: 16.66666667%;
}
.col-xs-pull-1 {
  right: 8.33333333%;
}
.col-xs-pull-0 {
  right: auto;
}
.col-xs-push-12 {
  left: 100%;
}
.col-xs-push-11 {
  left: 91.66666667%;
}
.col-xs-push-10 {
  left: 83.33333333%;
}
.col-xs-push-9 {
  left: 75%;
}
.col-xs-push-8 {
  left: 66.66666667%;
}
.col-xs-push-7 {
  left: 58.33333333%;
}
.col-xs-push-6 {
  left: 50%;
}
.col-xs-push-5 {
  left: 41.66666667%;
}
.col-xs-push-4 {
  left: 33.33333333%;
}
.col-xs-push-3 {
  left: 25%;
}
.col-xs-push-2 {
  left: 16.66666667%;
}
.col-xs-push-1 {
  left: 8.33333333%;
}
.col-xs-push-0 {
  left: auto;
}
.col-xs-offset-12 {
  margin-left: 100%;
}
.col-xs-offset-11 {
  margin-left: 91.66666667%;
}
.col-xs-offset-10 {
  margin-left: 83.33333333%;
}
.col-xs-offset-9 {
  margin-left: 75%;
}
.col-xs-offset-8 {
  margin-left: 66.66666667%;
}
.col-xs-offset-7 {
  margin-left: 58.33333333%;
}
.col-xs-offset-6 {
  margin-left: 50%;
}
.col-xs-offset-5 {
  margin-left: 41.66666667%;
}
.col-xs-offset-4 {
  margin-left: 33.33333333%;
}
.col-xs-offset-3 {
  margin-left: 25%;
}
.col-xs-offset-2 {
  margin-left: 16.66666667%;
}
.col-xs-offset-1 {
  margin-left: 8.33333333%;
}
.col-xs-offset-0 {
  margin-left: 0%;
}
@media (min-width: 768px) {
  .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6, .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .col-sm-12 {
float: left;
  }
  .col-sm-12 {
width: 100%;
  }
  .col-sm-11 {
width: 91.66666667%;
  }
  .col-sm-10 {
width: 83.33333333%;
  }
  .col-sm-9 {
width: 75%;
  }
  .col-sm-8 {
width: 66.66666667%;
  }
  .col-sm-7 {
width: 58.33333333%;
  }
  .col-sm-6 {
width: 50%;
  }
  .col-sm-5 {
width: 41.66666667%;
  }
  .col-sm-4 {
width: 33.33333333%;
  }
  .col-sm-3 {
width: 25%;
  }
  .col-sm-2 {
width: 16.66666667%;
  }
  .col-sm-1 {
width: 8.33333333%;
  }
  .col-sm-pull-12 {
right: 100%;
  }
  .col-sm-pull-11 {
right: 91.66666667%;
  }
  .col-sm-pull-10 {
right: 83.33333333%;
  }
  .col-sm-pull-9 {
right: 75%;
  }
  .col-sm-pull-8 {
right: 66.66666667%;
  }
  .col-sm-pull-7 {
right: 58.33333333%;
  }
  .col-sm-pull-6 {
right: 50%;
  }
  .col-sm-pull-5 {
right: 41.66666667%;
  }
  .col-sm-pull-4 {
right: 33.33333333%;
  }
  .col-sm-pull-3 {
right: 25%;
  }
  .col-sm-pull-2 {
right: 16.66666667%;
  }
  .col-sm-pull-1 {
right: 8.33333333%;
  }
  .col-sm-pull-0 {
right: auto;
  }
  .col-sm-push-12 {
left: 100%;
  }
  .col-sm-push-11 {
left: 91.66666667%;
  }
  .col-sm-push-10 {
left: 83.33333333%;
  }
  .col-sm-push-9 {
left: 75%;
  }
  .col-sm-push-8 {
left: 66.66666667%;
  }
  .col-sm-push-7 {
left: 58.33333333%;
  }
  .col-sm-push-6 {
left: 50%;
  }
  .col-sm-push-5 {
left: 41.66666667%;
  }
  .col-sm-push-4 {
left: 33.33333333%;
  }
  .col-sm-push-3 {
left: 25%;
  }
  .col-sm-push-2 {
left: 16.66666667%;
  }
  .col-sm-push-1 {
left: 8.33333333%;
  }
  .col-sm-push-0 {
left: auto;
  }
  .col-sm-offset-12 {
margin-left: 100%;
  }
  .col-sm-offset-11 {
margin-left: 91.66666667%;
  }
  .col-sm-offset-10 {
margin-left: 83.33333333%;
  }
  .col-sm-offset-9 {
margin-left: 75%;
  }
  .col-sm-offset-8 {
margin-left: 66.66666667%;
  }
  .col-sm-offset-7 {
margin-left: 58.33333333%;
  }
  .col-sm-offset-6 {
margin-left: 50%;
  }
  .col-sm-offset-5 {
margin-left: 41.66666667%;
  }
  .col-sm-offset-4 {
margin-left: 33.33333333%;
  }
  .col-sm-offset-3 {
margin-left: 25%;
  }
  .col-sm-offset-2 {
margin-left: 16.66666667%;
  }
  .col-sm-offset-1 {
margin-left: 8.33333333%;
  }
  .col-sm-offset-0 {
margin-left: 0%;
  }
}
@media (min-width: 992px) {
  .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12 {
float: left;
  }
  .col-md-12 {
width: 100%;
  }
  .col-md-11 {
width: 91.66666667%;
  }
  .col-md-10 {
width: 83.33333333%;
  }
  .col-md-9 {
width: 75%;
  }
  .col-md-8 {
width: 66.66666667%;
  }
  .col-md-7 {
width: 58.33333333%;
  }
  .col-md-6 {
width: 50%;
  }
  .col-md-5 {
width: 41.66666667%;
  }
  .col-md-4 {
width: 33.33333333%;
  }
  .col-md-3 {
width: 25%;
  }
  .col-md-2 {
width: 16.66666667%;
  }
  .col-md-1 {
width: 8.33333333%;
  }
  .col-md-pull-12 {
right: 100%;
  }
  .col-md-pull-11 {
right: 91.66666667%;
  }
  .col-md-pull-10 {
right: 83.33333333%;
  }
  .col-md-pull-9 {
right: 75%;
  }
  .col-md-pull-8 {
right: 66.66666667%;
  }
  .col-md-pull-7 {
right: 58.33333333%;
  }
  .col-md-pull-6 {
right: 50%;
  }
  .col-md-pull-5 {
right: 41.66666667%;
  }
  .col-md-pull-4 {
right: 33.33333333%;
  }
  .col-md-pull-3 {
right: 25%;
  }
  .col-md-pull-2 {
right: 16.66666667%;
  }
  .col-md-pull-1 {
right: 8.33333333%;
  }
  .col-md-pull-0 {
right: auto;
  }
  .col-md-push-12 {
left: 100%;
  }
  .col-md-push-11 {
left: 91.66666667%;
  }
  .col-md-push-10 {
left: 83.33333333%;
  }
  .col-md-push-9 {
left: 75%;
  }
  .col-md-push-8 {
left: 66.66666667%;
  }
  .col-md-push-7 {
left: 58.33333333%;
  }
  .col-md-push-6 {
left: 50%;
  }
  .col-md-push-5 {
left: 41.66666667%;
  }
  .col-md-push-4 {
left: 33.33333333%;
  }
  .col-md-push-3 {
left: 25%;
  }
  .col-md-push-2 {
left: 16.66666667%;
  }
  .col-md-push-1 {
left: 8.33333333%;
  }
  .col-md-push-0 {
left: auto;
  }
  .col-md-offset-12 {
margin-left: 100%;
  }
  .col-md-offset-11 {
margin-left: 91.66666667%;
  }
  .col-md-offset-10 {
margin-left: 83.33333333%;
  }
  .col-md-offset-9 {
margin-left: 75%;
  }
  .col-md-offset-8 {
margin-left: 66.66666667%;
  }
  .col-md-offset-7 {
margin-left: 58.33333333%;
  }
  .col-md-offset-6 {
margin-left: 50%;
  }
  .col-md-offset-5 {
margin-left: 41.66666667%;
  }
  .col-md-offset-4 {
margin-left: 33.33333333%;
  }
  .col-md-offset-3 {
margin-left: 25%;
  }
  .col-md-offset-2 {
margin-left: 16.66666667%;
  }
  .col-md-offset-1 {
margin-left: 8.33333333%;
  }
  .col-md-offset-0 {
margin-left: 0%;
  }
}
@media (min-width: 1200px) {
  .col-lg-1, .col-lg-2, .col-lg-3, .col-lg-4, .col-lg-5, .col-lg-6, .col-lg-7, .col-lg-8, .col-lg-9, .col-lg-10, .col-lg-11, .col-lg-12 {
float: left;
  }
  .col-lg-12 {
width: 100%;
  }
  .col-lg-11 {
width: 91.66666667%;
  }
  .col-lg-10 {
width: 83.33333333%;
  }
  .col-lg-9 {
width: 75%;
  }
  .col-lg-8 {
width: 66.66666667%;
  }
  .col-lg-7 {
width: 58.33333333%;
  }
  .col-lg-6 {
width: 50%;
  }
  .col-lg-5 {
width: 41.66666667%;
  }
  .col-lg-4 {
width: 33.33333333%;
  }
  .col-lg-3 {
width: 25%;
  }
  .col-lg-2 {
width: 16.66666667%;
  }
  .col-lg-1 {
width: 8.33333333%;
  }
  .col-lg-pull-12 {
right: 100%;
  }
  .col-lg-pull-11 {
right: 91.66666667%;
  }
  .col-lg-pull-10 {
right: 83.33333333%;
  }
  .col-lg-pull-9 {
right: 75%;
  }
  .col-lg-pull-8 {
right: 66.66666667%;
  }
  .col-lg-pull-7 {
right: 58.33333333%;
  }
  .col-lg-pull-6 {
right: 50%;
  }
  .col-lg-pull-5 {
right: 41.66666667%;
  }
  .col-lg-pull-4 {
right: 33.33333333%;
  }
  .col-lg-pull-3 {
right: 25%;
  }
  .col-lg-pull-2 {
right: 16.66666667%;
  }
  .col-lg-pull-1 {
right: 8.33333333%;
  }
  .col-lg-pull-0 {
right: auto;
  }
  .col-lg-push-12 {
left: 100%;
  }
  .col-lg-push-11 {
left: 91.66666667%;
  }
  .col-lg-push-10 {
left: 83.33333333%;
  }
  .col-lg-push-9 {
left: 75%;
  }
  .col-lg-push-8 {
left: 66.66666667%;
  }
  .col-lg-push-7 {
left: 58.33333333%;
  }
  .col-lg-push-6 {
left: 50%;
  }
  .col-lg-push-5 {
left: 41.66666667%;
  }
  .col-lg-push-4 {
left: 33.33333333%;
  }
  .col-lg-push-3 {
left: 25%;
  }
  .col-lg-push-2 {
left: 16.66666667%;
  }
  .col-lg-push-1 {
left: 8.33333333%;
  }
  .col-lg-push-0 {
left: auto;
  }
  .col-lg-offset-12 {
margin-left: 100%;
  }
  .col-lg-offset-11 {
margin-left: 91.66666667%;
  }
  .col-lg-offset-10 {
margin-left: 83.33333333%;
  }
  .col-lg-offset-9 {
margin-left: 75%;
  }
  .col-lg-offset-8 {
margin-left: 66.66666667%;
  }
  .col-lg-offset-7 {
margin-left: 58.33333333%;
  }
  .col-lg-offset-6 {
margin-left: 50%;
  }
  .col-lg-offset-5 {
margin-left: 41.66666667%;
  }
  .col-lg-offset-4 {
margin-left: 33.33333333%;
  }
  .col-lg-offset-3 {
margin-left: 25%;
  }
  .col-lg-offset-2 {
margin-left: 16.66666667%;
  }
  .col-lg-offset-1 {
margin-left: 8.33333333%;
  }
  .col-lg-offset-0 {
margin-left: 0%;
  }
}

.row:before,
.row:after {
  content: " ";
  display: table;
}

.row:after {
  clear: both;
}

/* Well */
.well {
height: 127px;
padding: 5px;
margin-bottom: 30px;
background-color: #dddde1;
border-radius: 4px;
}

.well-lg {
padding: 24px;
border-radius: 6px
}

.well-sm {
padding: 9px;
border-radius: 3px
}

/* Text helpers */
.text-left {
text-align: left
}

.text-right {
text-align: right
}

.text-center {
text-align: center
}

.text-justify {
text-align: justify
}

.text-nowrap {
white-space: nowrap
}

.text-lowercase {
text-transform: lowercase
}

.text-uppercase {
text-transform: uppercase
}

.text-capitalize {
text-transform: capitalize
}

/* Screenshot names */
.screenshot-name {
padding-top: 20px; 
padding-bottom: 30px;
}

.text-muted {
color: #777
}

/* Quick link */
.quick-link {
text-decoration: none;
}

.quick-link__value {
color: #fff;
padding-bottom: 5px;
}

.quick-link__description {
color: #333;
}

/* IMG */

.heightSet {
    max-height: 50px;
}

/* PAGE */

p {
    page-break-after: always;
}

.footer {
    position: fixed;
    bottom: 0px;
}

.pagenum:before {
    content: counter(page);
}


/*

        </style>
      </head>
      <body>

        <br/>
        <div align="right">
          <a href="https://www.advancedinstaller.com/repackager.html">
            <svg
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:cc="http://creativecommons.org/ns#"
              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              viewBox="0 0 375 64"
              width="375"
              height="64"
              version="1.1"
              id="svg_logo">
              <metadata id="metadata">
                <rdf:RDF>
                  <cc:Work rdf:about="">
                    <dc:format>image/svg+xml</dc:format>
                    <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/>
                  </cc:Work>
                </rdf:RDF>
              </metadata>
              <image
                x="0"
                y="0"
                width="375" 
                height="64"
                style="image-rendering:optimizeQuality"
                xlink:href="data:image/png;base64,
                            iVBORw0KGgoAAAANSUhEUgAAAVQAAABuCAYAAAB4BOvKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAF79JRE
                            FUeNrsnV1sHNd1xy8ZxRKkqFk2gd24iLVyAMt1W3sVqG5RGOISSPxSFFy++oVLoH3oS0kCAewWhUnaQZuHoEsiQF6SgrsFGuSNS7fI
                            Qz7ApZq4geFKqxRI5aJwRgKqQI4crutKlVIZ6j2zZ8jLwzszd2Zn9oP8/4ABubszd+6cufc/59yvUQoAAAAAAAAAAAAAAAAAAAAAAA
                            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACGkLFRzfjspYcl/acQ9nvj4lgLtxcAAEHdL5wkmmW9TeqtxFshQRIkrG29XaX/tdB6uO0A
                            gCMjqOx9zrKQlszfPn1Cb8eVeuITSp08tvf9zZs31b3/vbf7+db4hPrV2DG1M3ZaJk+C2iQnVotrG0UAAHDoBJU90Yre5k0RffqTei
                            vw30+GH//222+rnZ0d628746d9gaXtvfFfV79Sx0xxbehtVYtrB8UBADDSgspCusBC6ofyn//U3mZ6oVFECarJxMSEGj97QV1+X6kf
                            3tr9usNe6wqaBAAAIymoWkxJSJdISEk4X3hMqRcf74b1SUkiqBcuXPD/v/tAqe/e1Nt/df9nVuCxAgBGRlC1kJb1n1oQ2lfOdIXU1R
                            vNSlADLMJKYjqnRbWJIgIAGFpB1WK6zF6pH9K/9GQ6jzRLQTWFtXmjK6xMk4UV3ioAIJZj/ToRt5VukVdKnuifPNUV1GGC8kUCT/n6
                            5n8odfue30lW0nmfwYgAAEAc430SUwrtf0biRD31X/294RNTE8rja+e7bbqaot6u6GuoorgAAAbqobIQUXtp4cXf7HqAzty+rdT777
                            vte/du5t4qedEkruStatb1tdAMrDqKDQDARq5tqCym6/Q/iRN7fO5sbnY3F15+Walz53K5jht3lPrKT3Y7rOpaVOdQdAAAfQv5exbT
                            IeKJU0q98uzuKIQqd6wBAED+gsptprXDIKYhorqENlUAQO6CqoWmqLq9+YXDIqYhorrO42kBACA3D3VDcQfUYRJTU1SNjrUNfoAAAE
                            C2gqrFxZ/9RD3jiXrzRwx6UNDsLtVde2AdxQgAQGQ2bIrD3wUKh//8mcNvuMoTSl3r6O0DVaZOqsbFseVhyNczpT8kkTeXPOz8tP1m
                            O6O0y3mkC6z29bR9vZj95drAbX1M55DZhCLA3ShQX1/LUsaH5roz8VB5FtRuj/7JY0ejAhjXOj9EoT9FCVvmxgUwC8x0a5DAzDHtW0
                            1xr0uH0CZVcY2Kr3Morzsr6aNVo4rBkntHBVqDgDzVb727G/pPDYF3WhFfB9/VoVcgZ+96y/hqirzJo2aHnj1U9szmg3nwRw3qfKOO
                            Kk15CHr9K8r+eph5VHkARsND9dczJWFxXTWKVoZy4fSpU+rc9LTTvu/cvq0+/PDD+DRPn1bnMp5R9dLnujOp2BaDfCrPhnxforaouD
                            Y5AMAABZXbTqvkndJ6pq64LLPnMzGh1Be+4LTrh47L9+VB8HoW7qAqD+KNq9x4b3rIq6rbFGN6qYso8gAMr4e6EIS9R6UjKjTWPrPr
                            pc4PyEuVYf2a6jbWByJbjRNULcq0zzQfQw/LNm8NW3uY3n/Z+Ei9/qsRaZv7Uq9sk78v8znNN9p6vNFCDk3Ts+Y8Fvkj9YTXOY3gXW
                            TFuHwbD6B5YaPguM0gfzF2Cs7n8XFrUe2GfNyscZ3B+VayjB6ysBHvP8v7mvbx2D51ca4z0t8yRi3Ug+tzuN/1LHrsjfwH5+kE91ae
                            g8tCNfisf1vm/giKOCt8fYtR5TsrQfVDzCTe6WGFPFRq8qA1VKldeQDvpjI7o3wR0oWiYVSGgv5csQkFFx5bb2lQGKt6H1thes48r9
                            6naRMGOi8XzoA5/n5d2Xuzi0ZFXtL7LQYVWO29DZegITT0dz0i33PGsUF+asJ7tx1HIjNjqXgbFjsF+a2EHOdi3yyjh9Q24rxuiGhH
                            HkPXSeI8Jc5lYt5XsomX8n6nEVPb/Q1eR+8/WPQ+M8awv6JZPqkc8/0qiONjSd0ppUXDV24a5H7UvdMA48FS6XO4XzE8EsVPYV9YbQ
                            9ACy5DT2wCtBkh6iayIbzJhb7qcHn+CAoWM1sFj5tYse9YrtQLDuelirc75Iz/XnGwk+04F/vmNQwtqY1qIQJpS3croci53u9ayP12
                            OY/L/S3yPQq7J+uuApqZoAaV5CgNk4rDmGo72+dTy/M1OXTpCFGtyILKIdu+iQDkQepjx2jT/5+1CLN5no6DYJtCW+fCuiDOOWOcc0
                            J1X5YY5vFIr4H2nTDy27Ydy2FgNeK858WxJWP/DVHJ5Dmb4rgF40GU1r5ZkMhGwj60z9kY+2yzpyo97EX+foqvOcn9LjiKr62poyrK
                            59mIc2xEPCwUN0Os8NbKW1Ar5JlCUPcw7FHq10B/y9jTpmiDivMil8TnGTPcohBebzO2AmUR7JJFsOVQrk3hTStun2qa6VI7lqXS21
                            ilfYNr5iaHGUvThO1ap8R524YA7DoO7MmURX73ndNioyW+N7OWczrZN0OcbGTxCjfNJhy2z6KlHLQs94rayVv8m0x3rof7HYV5f+nc
                            M0H+jXOY+S+yCNugdtazbLdl1zG1qQSVx1sWIKYHobZUI/TrB7JANGK8yHnRJlgUYhxWcMLa+OIEe9L0TLgieYb3MmXz0FiMXMKuNU
                            sF98Q1Fzi9sqgw7ZCHxBoLXMvieXsRnROLlgpejDun4UHmhZONLO3f1NZYNWfasUiOGduyw/nb4n63Qu53aieEH3rFOHvyvfMimqOC
                            e5xqEfm0rZ9lIR4gENTCPiGp9znc78hOJxIIbmSvGk/lcojnEPp6BBICfVxHihydT3/vGWlRflZDBLZpVGZPVIgyp00V44wKn6RgE4
                            awSly2hHEu17os8rYlPi8nqSeO5ww6jzIngY0Ui13ZCIupPXGdO9to/6uWKMjl/Jnc76iIWdperI0QdY/W4h5AeQvqJATVDs2aotD/
                            7oP8PVR+KpeiKn8gohYRtnminoOnYbuuptFGtjuJwOI1rAmPZEHtDaHpN0mG5hSELZccjyslPGerj5FNGNQUYOtEKxt5CwR20XWBnA
                            Hc76UU99Ys530VVP9V0PtmRiV5od4goZf5vfOO276f/axWx5OpRPXaB+nDlwTMWwqHS4WsZDxMp6H2dzpU2EuVoXLbqFxhPd+BN9NW
                            br3xw0ynR6+r77Dned4yJtnm2VFP+VScqMbc77baGyM66vc7taAWeP76Hj/6kfML9b7o+kI9Su/rX3dK8wKleeGCW5p1x0g85Yv/KO
                            zXgqr6MGsq7fCsoCPLc3haR3lcZnNA2/g9CPsPhPtMTaRFvx0YFK/TzLOCFSIEoCg8a9OzpDZEp0VwLAuGJG0iGKSw1oMmKyMSmhSh
                            edAkcD4mub7fb+7ZVwnu02AENVgAxHXe/lHk5MdCQ+0sw/2qEIW6OtghJcWwJrxbKQzTKmQIj9HmFeWlloywvxIW7gvhaHMvd97Ih8
                            ekCh+utG7k0RPNI6UeKud0SFNLMBpioHDezfyvcu94MKuqzpGN6W26hO/9uN9tac+w2W5iHdlM11FNPWwKghoR8n8if0FVB4fjrAXD
                            VEI22btpTn8MqEYMdo5rk2pavBKzEpnnLkYIXeZeA3ssnjhX1bZOrGWIFAngtunZhnlS/JCTa3fKcxZT2rcflDgfwVYOaRLYTJhuUd
                            gzj/vdiqkfsvkh2DIdMz6e0uhgsJ5EURR2z7FzQIrevDrYo7llFm4qgHrbiAtHWbCaIZWoEeEtluVYQP4sB12fycB0cmD3vtky/L+c
                            VdTg8NfMc02KKtusJu5JS9jXH0wu7Ftk+w5DvZKitC6FzlgTIPKBqLpDrgpcVjvioVJ2uN+JurxZ6OvGV9RPsG4+NDkvckrpWpYGTN
                            OG6mcGPfwRIf+xTEXARlV6p47Hyc6jqi6IE7qgmfOxA6HxuCIkqejkuVQchLxheGTB1NJ1Fd3LXbU8SJJ6qXVxrXRtV/habRFF3Wjn
                            m1P720NrPJ2yZXj7JnN8zlU+pxkip7VvrnBbeNO4h0FZCDqNbLZftIXcnEbFEN1CgjSJhYhoKYxFTq9o1JMqt+/bxrmu8miUzCLJcc
                            hfDiH/qdxD/tkYwQqtMMKjKHDbnW2mTlFU9raKH07StLRJ2RZMWQ1Jy6xcHUuesmgGmLHYqxgipnOG7Vp8bMeSp4LI94zocJmyXG8a
                            +/aDOYvdw0aPrATtlBYPUQpdOybNnu8358Fm61KImGa+nCWWNRnNcN8MoTsJl36bkwU1KIjG8nJlUdE31V6vfTEs1ONJBIsqps2M95
                            tS9nGJLT5fUDnN5oY2//6Boze+LfPK1zpjhK6mIAaV2roMH09iaIXke9dOctC7GIpks2+DPdmqYbtWwms0r1N+72wjURZsw6baho08
                            cZ1z+rhtPk4e43K/g1EDZWHTbUuT0Yqt2YHzFGZrj88nlywMTS8pY0kPoDd8Urj2yrMi7KfhSI7DplSSYVOjkKYtPv3nbmFpXBybUg
                            CAI0GakN93p2/8D4wXxo07sAEAEFQ3/HDm7kcwXhh3H+z+uw1rAHB0SNOG2hGi0eXpp50TePvWLaVcXqiXx0v6EqTpnM8cXvwHADgC
                            gtq4ONaevfTwYMhPguIoKjvf+55S9+/H75jHS/oSpOmcT8G1vS4TD0UMAIT8cXjD3E64M35avde5P7DzG947BBUAeKixtLVoFG/fG/
                            wUVPIGyVu++tHn1O1HlLo1PuF//+2vvq4enTiufvfsr+1ujxaO9yVPhvfeRhEDAIIaBy0yWyExe6FPgkriffv+noCSh0zfGbH8AX/7
                            vZ376gc7v1A/uPwL//OpE8fU8888qv7oPz9SFz9fVM8+9VhuIk/eaePiWCfrtF/5i+Wicpww8JW/WW6lSN8268fpIavP1+kl3TT5jb
                            NNr2kaaQcrdJnp++NW9TnaKdIqueZT719Oam8H23SS5jsm7bI6uEYD2cZLkV45TT5ibHjA5mnLch6CShlf8gU1B02ikH1n7LT66MGE
                            +v5PuuJ5oBMsBXfuPVBbl2/6G1E4fUIL6xl/e/ap3/D/ZiSmgY3yoKocF9LQhSgo2A1dQJYd03d966VkKuaaY9Pl/BL+8m4pxHBJiW
                            m5Os2pXkSVxeJAumIfsvGiPo/ry/ZsbwwdC0nb9urlYKB8Eg6sF6DTnkgrHMZDMvK+6n1abJsk4r2VMktjCW0edW3B+9IWk9goVRsq
                            r/HZufZB7+pAIfq1Y0+of/n4b6vvP3JB/cOJL6rvPPIH/ue3/u9xX6CyEFMbnQ/vqTe231Ffqn1Xvfhnf69O/P7r/t8vf/OSunT5eq
                            o0L++tsT0sQ6Z8QdAF5MoIRU7kCW7pPFdTeJCS2R4Eg9K7ouLfwEk23mDxyzIaCRXThN5pKcQ7q/aQtyrbJu7hW056L4eE4M2rV7hs
                            5SeogQdGIbdr5xTtS2LTvKGV5pHnVPP4C754koj+67Fz6t2PPb7b/jlISEi//I1tX1j/+K9+rP7y736qvvGd6+rH/76jPdz4wbfXOr
                            l7qGkp6YKxPGKFej1B+Bf2TqJKkgohRGgjYfNHNSsbZyWmMQ+V2ZR5o3ytJxSndbbpqFFU4a+bzizkJ/yVhX54S6mXntz/A4ls0M4Z
                            /N3nZY4/OjLW/Lef/be/vfHmz/3PT37mlPod7uR68jMn93V0GQ+YtvbivT5l0fpqX9WdM10VgkBz15NW+Jajt530eutq/5oEBSPPSu
                            S51YNoBJ5rPaG3a6tEflME27zI6crmF4oG6mnaDnMS0yhPlB6ypSThODeB1Cw/0VoPm9S8wsI5bzlvLUVTRVBWrudQd6ZCmgaWRL0p
                            03W73NNeBJUKV00LauHTx/eL52Hm3Z/f8bdAYGkkwfO/9ZiavvVx9ctPnQnuQ6OPWeqEtBFSwb4uCn+azqbtBO2vSbhuyXdT5/mqyH
                            PFsZKXY8S2nlCAiuI7aktbFQLX1uducugrj09lM/b+MhNTbrYoxNgmSfvmkiW9OZ23XfuyQM9Z7mU5qYAzjaw6F00i6g3lb8viqcYK
                            aqKQf/bSwwotjqK3DS5EBfI8v/WuUuSpHsU57DSS4J/evKH+9LU31MvzX1P/+NdfU82Vv508/vxrC3obdIgzisO2mimOqcakUWbRdU
                            W+/LAlxFQJ8ZC/TWYYSvfimdo891VH7zXMc5f7100xFbZZtYhQedgLYC/indRD3VAgkju/7ARele9ZaVH1h9bcf+vVmQFkpzCCJixk
                            IBorFu/WyWsMGZYWt4A3nc9cwiyNJ5m5mIZ01K2o/cO/CuTFOo5QKIdcexQz4p56w14AQ9rcne4B1kPtj0BUBlQoljLw/mZ1WnEeVy
                            PMS0nBfJKCzJ1WpgB65DXq7+XbA2Ydw3CbJ9uK8Wg6qvdOSFsnz0ovw5psnjulx80UC8I2LmVDRlxeXLtiRmNdazyMKYrFrMbVqoNt
                            xJ5r2hDU0Yc6FrYsIl6yCFOaFcqLKn4iQZohYpOWHvFpS77jKrr17QUk8Dr9muEdFUl8HcK5YohgDgLqGW/1cH75cGoYf01B9UdCpD
                            iPZ3nAlZS902rX69bnSVoOXZrO0ozk2HL0wp3zC0E9HB5w2aHgT/XS85wDZYd8d6JCypA2vTUhrlUhvokFdcD3dp3D5qRiIV/70QnC
                            evbgPfE72Wm1T+VxmMpgXPmbSdKmindKHQ2KKv1rilssalFbK4c8dxweAhWL92PuL1/N4DImtTXA+xS8uE7muZqBd9qMePDYPP1hou
                            5QBvNwFgrc3ODs/cJDHX1s41CL6uD7dGjQ+XaKts68hk1FCYr/jiGHEFSKRiEkjDMrSKIxqYG3F9WGZgtz9f5TKa49OEYOw6px6J9E
                            NOTDpixsI0XCZUxqx8HD80RUcUb1MCMraKLIY9iUOjgOlerNpMhvcG/nIKhHg7BxqHWuQGahn04qJjmy0otQc298yVIh4kL2yDGpPD
                            C9IwQnbqymbL5I0zkyFYiZPv+KiCiCiQbnHW1TtQimq23aSbx3OpcYg0qCuizyUh3GihNRb5TIs3MTBkL+w03DUqkOC/Mpj3MZkyrD
                            44WwaZMcDs5booaklbtt/L9sSSPJ1OHplLapOuRReslLMSHx/AiWrbW09QYe6uFGFv40Ew3OOM6n9/rc6SVDWvKSrkd4XkUhHFHitG
                            IRF1rgY18HBQvzhko+btWFOUvov8ShfyvGc5e2oc6msKWMlkSTSdyYVLLNuhAbss2c+VBgka2lLHPK8jBx2a+dxYgM7rQ7YNe8p56C
                            0RPUtF6LS8i2olJOt0wR7leUfWpoJ2R/euG5HHe5HFGhPH3MqjimwMLhGXa1PWiaWYyH5EotQ3+ChlKdjxCOiuVBtxhhSzlULXJMKg
                            9Hk+3zdPwVnrLZSRomO1BzbTZR+XUqFlXWU0/BaGF7oqZZeWkImbaIWCdJ00ec180iVA+pWOUQwWgrx84Lx/tnC/2LMQIzH3PtcbZx
                            GQkxE9KsUVJuw+FGgVTCDEE9/Lj0zI4MIWNPN+O8PYt3ETtMSB83x563SxhJXt1UDpMAZiznr7KXLm1TtnjudYd826KSKLsEIxJWHe
                            0ycwjqjVO7NEL+0X9yxoUhiypZZxR5LNsZ5Csu3bShWUEdHOzvMm1yUYS2TsJHXiKH/1WuVEXDni321BoJw3xPxc+BN5sf5pR9RENY
                            08vuNTpMDQ3SLyaxDYvqoj52jW0zyXks8PWRPdZ41IR5zzyHy15JWTa8LGzO0HVdTVDPfMaS5Hb20sOHo6I63/7S60OVn/tvvTqmAA
                            CHGoT8AAAAQQUAAAgqAABAUAEAAEBQAQAAggoAABBUAACAoEZCA5xbKsVLyAAA4LCTaKZU4+LY7iILs5ceFlV3ZgRt5iwJsDdThGYG
                            te+/9WoLJgEAgholrh4LRxMi64sniSZNVaNXRnsoWgBAUHviiIhsx/A+W/A+AQC5COohFVmPvc8gfG+j2AAABiKoKUX2Of5bHED2Ws
                            IDRQccAGB4BTWByBbU3qK1eYhsR3ifCN8BAKMvqCEiGwheKyORRecRAOBoCmqPIlswQ3f2QBG+AwAAAAAAAAAAAAAAAAAAAAAAAAAA
                            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASMH/CzAA2Yd2N+Ti1SIAAAAASUVORK5CYII="/>
            </svg>
          </a>
        </div>
        <br/><br/><br/><br/><br/><br/>

        <xsl:variable name="productName">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="cell[1][@value='Product Name']">
              <xsl:value-of select="*[2]/@value"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="productVersion">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="cell[1][@value='Product Version']">
              <xsl:value-of select="*[2]/@value"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="productCompany">
          <xsl:for-each select="report/tables/table[@name='Product Details']/rows/row">
            <xsl:if test="cell[1][@value='Product Company']">
              <xsl:value-of select="*[2]/@value"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        
        <div class="text-left h2">
          Repack Session Report for <xsl:value-of select="$productName"/><br/>
          version <xsl:value-of select="$productVersion"/>, a product of <xsl:value-of select="$productCompany"/>
        </div>
        
        <br/><br/>

        <h3>Package Content</h3>
        <div class="row">
          <xsl:for-each select="report/tables/table">
            <xsl:if test="position() != 1">
              <div class="col-xs-2">
                <a href="#{position()}" style="display:block;position:absolute; width:100%; height:100%; top:0; left: 0; z-index: 10;">
                  <div class="well">
                    <div class="text-right h1">
                      <div class="quick-link__value">
                        <a style="color:white; text-decoration:none" href="#{position()}">
                          <xsl:value-of select="@count"/>
                        </a>
                      </div>
                    </div>
                    <div class="text-left text-uppercase h5">
                      <div class="quick-link__description">
                        <a style="color:black; text-decoration:none" href="#{position()}">
                          <xsl:value-of select="@name"/>
                        </a>
                      </div>
                    </div>
                  </div>
                </a>
              </div>
            </xsl:if>
          </xsl:for-each>
        </div>

        <p>
          <!-- pagebreak -->
        </p>

        <xsl:for-each select="report/tables/table">
          <xsl:if test="position()!=1">
            <h3 id="{position()}" style="page-break-inside: avoid !important">
              <xsl:value-of select="@name"/> (<xsl:value-of select="@count"/>)
            </h3>
            
            <table align="center" style="border-collapse:collapse; table-layout:fixed">
              <xsl:choose>
                <xsl:when test="@name='Screenshots'">
                  <xsl:attribute name="class">table</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="class">table table-striped table-bordered</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              
              <xsl:variable name="hideHeader">
                <xsl:for-each select="columns/column">
                  <xsl:if test="@name=''">
                    <xsl:value-of select="1"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              
              <xsl:if test="$hideHeader!='1'">
                <xsl:for-each select="columns/column">
                  <col style="width: {@width}%"/>
                </xsl:for-each>  
                <thead style="page-break-inside: avoid !important">
                  <tr>
                    <xsl:for-each select="columns/column">
                      <th>
                        <xsl:value-of select="@name"/>
                      </th>
                    </xsl:for-each>
                  </tr>
                </thead>
              </xsl:if>
              
              <xsl:choose>
              
                <xsl:when test="@name='Screenshots'">
                  <tbody style="overflow-wrap:break-word; word-wrap:break-word; page-break-inside: avoid !important">
                    <xsl:for-each select="rows/row">
                      <tr>
                        <td>
                          <center>
                            <img style="max-height: 100%;max-width: 100%;" src="data:image/png;base64,{cell[1]/@value}"/>
                          </center>
                          <center class="screenshot-name" style="font-family: 'Segoe UI', Arial, Helvetica, serif;">
                            <xsl:value-of select="cell[2]/@value"/>
                          </center>
                        </td>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </xsl:when>
                
                <xsl:when test="@name='Notes'">
                    <tbody style="overflow-wrap:break-word; word-wrap:break-word; page-break-inside: avoid !important">
                      <xsl:for-each select="rows/row">
                        <tr>
                          <xsl:for-each select="cell">
                            <td>
                              <xsl:call-template name="ReplaceNewlinesWithBreaks">
                                <xsl:with-param name="aText" select="@value"/>
                              </xsl:call-template>
                            </td>
                          </xsl:for-each>
                        </tr>
                      </xsl:for-each>
                    </tbody>
                </xsl:when>
                
                <xsl:otherwise>
                  <tbody style="overflow-wrap:break-word; word-wrap:break-word; page-break-inside: avoid !important">
                    <xsl:for-each select="rows/row">
                      <tr>
                        <xsl:for-each select="cell">
                          <td>
                            <xsl:value-of select="@value"/>
                          </td>
                        </xsl:for-each>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </xsl:otherwise>

              </xsl:choose>
            </table>
            <br/>
          </xsl:if>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>
  
  
  <xsl:template name="ReplaceNewlinesWithBreaks">
   <xsl:param name="aText" select="string(@value)"/>
   <xsl:choose>
     <xsl:when test="contains($aText, '&#xa;')">
       <xsl:value-of select="substring-before($aText, '&#xa;')"/>
       <br/>
       <xsl:call-template name="ReplaceNewlinesWithBreaks">
         <xsl:with-param 
           name="aText" 
           select="substring-after($aText, '&#xa;')"
         />
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$aText"/>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>