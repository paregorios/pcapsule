<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://nowhere.com"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output method="xml" encoding="UTF-8" exclude-result-prefixes="#all" indent="yes"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//t:text/t:body"/>
  </xsl:template>
  
  <xsl:template match="t:body">
    <text>
      <xsl:apply-templates select="t:div1"/>
    </text>
  </xsl:template>
  
  <xsl:template match="t:div1[@type='Book']">
    <xsl:call-template name="where"/>
    <book>
      <xsl:copy-of select="@n"/>
      <xsl:for-each select="t:p">
        <xsl:for-each select="t:milestone[@unit='chapter']">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
      </xsl:for-each>
    </book>
  </xsl:template>
  
  <xsl:template match="t:milestone[@unit='chapter']">
    <xsl:message>milestone chapter = <xsl:value-of select="@n"/></xsl:message>
    <xsl:call-template name="where"/>    
    <chapter>
      <xsl:copy-of select="@n"/>
      <xsl:variable name="cnum" select="@n"/>
      <xsl:apply-templates select="following-sibling::t:milestone[@unit='section' and preceding-sibling::t:milestone[@unit='chapter'][1]/@n=$cnum]"/>
    </chapter>
  </xsl:template>
  
  <xsl:template match="t:milestone[@unit='section']">
    <xsl:call-template name="where"/>    
    <section>
      <xsl:copy-of select="@n"/>
      <xsl:variable name="cnum" 
        select="preceding-sibling::t:milestone[@unit='chapter'][1]/@n"/>
      <xsl:variable name="snum" select="@n"/>
      <xsl:apply-templates
        select="following-sibling::node()[preceding-sibling::t:milestone[@unit='chapter'][1]/@n=$cnum and preceding-sibling::t:milestone[@unit='section'][1]/@n=$snum]" mode="foo"/>
    </section>
  </xsl:template>
  
  <xsl:template match="t:div1">
    <xsl:message>untrapped div1 of type = <xsl:value-of select="@type"/></xsl:message>
  </xsl:template>
  
  <xsl:template match="t:milestone[@unit='para']" mode="foo">
    <br />
  </xsl:template>
  
  <xsl:template match="t:note[@resp='ed']" mode="foo"/>
  
  <xsl:template match="t:*" mode="foo">
    <xsl:apply-templates mode="foo"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="foo">
    <xsl:text></xsl:text><xsl:value-of select="."/><xsl:text></xsl:text>
  </xsl:template>
  
  <xsl:template name="where">
    <xsl:variable name="book" select="ancestor-or-self::t:div1[@type='Book'][1]/@n"/>
    <xsl:variable name="chapter">
      <xsl:choose>
        <xsl:when test="self::t:milestone[@unit='chapter']">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="preceding-sibling::t:milestone[@unit='chapter'][1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="section">
      <xsl:choose>
        <xsl:when test="self::t:milestone[@unit='section']">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="preceding-sibling::t:milestone[@unit='section'][1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:message><xsl:value-of select="$book"/>:<xsl:value-of select="$chapter"/>:<xsl:value-of select="$section"/></xsl:message>
  </xsl:template>
</xsl:stylesheet>