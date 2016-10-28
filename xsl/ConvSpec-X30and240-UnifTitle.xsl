<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bibframe/lc-extensions/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

  <!--
      Conversion specs for Uniform Titles
  -->

  <!-- bf:Work properties from Uniform Title fields -->
  <xsl:template match="marc:datafield[@tag='130' or @tag='240']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="titleiri"><xsl:value-of select="$recordid"/>#Title<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="workUnifTitle" select=".">
      <xsl:with-param name="titleiri" select="$titleiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='730']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work730-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="titleiri"><xsl:value-of select="$recordid"/>#Title730-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work730" select=".">
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="titleiri" select="$titleiri"/>
      <xsl:with-param name="serialization" select="serialization"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="marc:datafield" mode="work730">
    <xsl:param name="workiri"/>
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:choose>
          <xsl:when test="@ind2='2'">
            <bf:hasPart>
              <bf:Work>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                <xsl:apply-templates select="." mode="workUnifTitle">
                  <xsl:with-param name="titleiri" select="$titleiri"/>
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Work>
            </bf:hasPart>
          </xsl:when>
          <xsl:otherwise>
            <bf:relatedTo>
              <bf:Work>
                <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                <xsl:apply-templates select="." mode="workUnifTitle">
                  <xsl:with-param name="titleiri" select="$titleiri"/>
                  <xsl:with-param name="serialization" select="$serialization"/>
                </xsl:apply-templates>
              </bf:Work>
            </bf:relatedTo>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='i']">
          <bflc:relationship>
            <bflc:Relationship>
              <bflc:relation>
                <rdf:Description>
                  <rdfs:label>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </rdf:Description>
              </bflc:relation>
              <bf:relatedTo><xsl:value-of select="$workiri"/></bf:relatedTo>
            </bflc:Relationship>
          </bflc:relationship>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='830']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work830-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="titleiri"><xsl:value-of select="$recordid"/>#Title830-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work830" select=".">
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="titleiri" select="$titleiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="marc:datafield" mode="work830">
    <xsl:param name="workiri"/>
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:hasSeries>
          <bf:Work>
            <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
            <xsl:apply-templates mode="workUnifTitle" select=".">
              <xsl:with-param name="titleiri" select="$titleiri"/>
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates>
          </bf:Work>
        </bf:hasSeries>
        <xsl:for-each select="marc:subfield[@code='v']">
          <bf:seriesEnumeration>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:seriesEnumeration>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>    
        
  <!-- can be applied by templates above or by name/subject templates -->
  <xsl:template match="marc:datafield" mode="workUnifTitle">
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:title>
          <xsl:apply-templates mode="titleUnifTitle" select=".">
            <xsl:with-param name="titleiri" select="$titleiri"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2='10')">
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="substring($tag,2,2)='30' or $tag='240'">
            <xsl:for-each select="marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:originDate>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:originDate>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2)='30' or $tag='240'">
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopBrackets">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:natureOfContent>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:natureOfContent>
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='l']">
          <bf:language>
            <bf:Language>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:Language>
          </bf:language>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m']">
          <bf:musicMedium>
            <bf:MusicMedium>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='o' or @code='s']">
          <bf:version>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:version>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r']">
          <bf:musicKey>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:musicKey>
        </xsl:for-each>
        <xsl:if test="substring($tag,1,1)='7' or substring($tag,1,1)='8'">
         <xsl:for-each select="marc:subfield[@code='x']">
           <bf:identifiedBy>
             <bf:Issn>
               <rdf:value><xsl:value-of select="."/></rdf:value>
             </bf:Issn>
           </bf:identifiedBy>
         </xsl:for-each>
        </xsl:if>
        <xsl:if test="substring($tag,2,2)='30' or $tag='240'">
          <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='0' or @code='w']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:if test="$tag='630' or $tag='730' or $tag='830'">
          <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:if test="$tag='730' or $tag='830'">
          <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
        <xsl:if test="$tag='830'">
          <xsl:apply-templates mode="subfield7" select="marc:subfield[@code='7']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- build a bf:Title entity -->
  <xsl:template match="marc:datafield" mode="titleUnifTitle">
    <xsl:param name="titleiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nfi">
      <xsl:choose>
        <xsl:when test="$tag='130' or $tag='630' or $tag='730'">
          <xsl:value-of select="@ind1"/>
        </xsl:when>
        <xsl:when test="$tag='240' or $tag='830'">
          <xsl:value-of select="@ind2"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='00'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t'] |
                                       marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or
                                         @code='g' or 
                                         @code='k' or
                                         @code='l' or
                                         @code='m' or
                                         @code='n' or
                                         @code='o' or
                                         @code='p' or
                                         @code='r' or
                                         @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='10'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t'] |
                                       marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d' or
                                         @code='f' or
                                         @code='g' or
                                         @code='k' or
                                         @code='l' or
                                         @code='m' or
                                         @code='n' or
                                         @code='o' or
                                         @code='p' or
                                         @code='r' or
                                         @code='s']"/>
        </xsl:when>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='t'] |
                                       marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or
                                         @code='g' or
                                         @code='k' or
                                         @code='l' or
                                         @code='n' or
                                         @code='p' or
                                         @code='s']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="concat-nodes-space"
                               select="marc:subfield[@code='a' or
                                   @code='d' or
                                   @code='f' or
                                   @code='g' or 
                                   @code='k' or
                                   @code='l' or
                                   @code='m' or
                                   @code='n' or
                                   @code='o' or
                                   @code='p' or
                                   @code='r' or
                                   @code='s']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$titleiri"/></xsl:attribute>
          <rdf:type>bf:WorkTitle</rdf:type>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:title00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title00MatchKey>
              </xsl:if>
              <bflc:title00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:title10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title10MatchKey>
              </xsl:if>
              <bflc:title10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title10MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:title11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title11MatchKey>
              </xsl:if>
              <bflc:title11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title11MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='30'">
              <xsl:if test="$label != ''">
                <bflc:title30MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title30MatchKey>
              </xsl:if>
              <bflc:title30MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title30MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='40'">
              <xsl:if test="$label != ''">
                <bflc:title40MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title40MatchKey>
              </xsl:if>
              <bflc:title40MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title40MarcKey>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label><xsl:value-of select="normalize-space($label)"/></rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="normalize-space(substring($label,$nfi+1))"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:for-each select="marc:subfield[@code='a' or @code='t']">
            <bf:mainTitle>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:mainTitle>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2) = '11'">
              <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
