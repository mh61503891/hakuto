require 'open-uri'
require 'nokogiri'
require 'rack/utils'

module Hakuto
  module API
    module ACM
      class Reader
        class << self

          def read(id)
            paper = {}
            paper.merge! read_citation(id)
            paper.merge! read_abstract(id)
            paper.merge! read_references(id)
            paper.merge! read_citings(id)
            if (!paper[:id] && !paper[:text])
              raise "paper is empty (#{id})"
            end
            return paper
          end

          def read_citation(id)
            doc = Nokogiri::HTML(open("http://dl.acm.org/citation.cfm?id=#{id}"))
            attrs = doc.xpath('html/head/meta[@name][@content]').map{ |meta|
              { meta.attr('name') => meta.attr('content') }
            }.inject(&:merge)
            return {} if attrs.nil? || attrs.empty?
            paper = {}
            if attrs['citation_abstract_html_url']
              paper[:id] = Rack::Utils.parse_query(URI.parse(attrs['citation_abstract_html_url']).query)['id'].split('.').last
            end
            if attrs['citation_authors']
              paper[:authors] = attrs['citation_authors'].split(';').map(&:strip)
            end
            if attrs['citation_date']
              paper[:day], paper[:month], paper[:year] = attrs['citation_date'].split('/').map(&:to_i)
            end
            if attrs['citation_keywords']
              paper[:keywords] = attrs['citation_keywords'].split(';').map{ |keyword|
                keyword.strip!
                keyword.squeeze!(' ')
                keyword.downcase!
                keyword
              }
            end
            {
              doi: 'citation_doi',
              title: 'citation_title',
            }.each do |key, value|
              if !attrs[value].nil? && !attrs[value].strip.empty?
                s = attrs[value]
                s.strip!
                s.squeeze!(' ')
                paper[key] = s
              end
            end
            if paper.empty?
              return {}
            else
              return paper
            end
          end

          def read_abstract(id)
            doc = Nokogiri::HTML(open("http://dl.acm.org/tab_abstract.cfm?id=#{id}"))
            abstract = doc.xpath('html/body/div/div').text.strip
            abstract.gsub!(' , ', ', ')
            abstract.squeeze!(' ')
            if abstract == 'An abstract is not available.' || abstract.empty?
              return {}
            else
              return { abstract:abstract }
            end
          end

          def read_references(id)
            doc = Nokogiri::HTML(open("http://dl.acm.org/tab_references.cfm?id=#{id}"))
            papers = []
            doc.xpath('//table/tr').each do |tr|
              td = tr.xpath('td')
              is_acm = td[0].xpath('boolean(img)')
              n = td[1].xpath('div/text()').text.strip.to_i
              anchors = td[2].xpath('div/a')
              case anchors.size
              when 0 # It does not exist in ACM DL
                text = td[2].xpath('div/text()').text.strip.gsub(' , ', ', ')
                year = text.scan(/\d{4}/).flatten.last.to_i
                papers << {
                  year:year,
                  text:text,
                }
              when 1 # It exists in ACM DL and has no DOI
                id_path = td[2].xpath('div/a').attr('href').value
                id = Rack::Utils.parse_query(URI.parse(id_path).query)['id']
                text = td[2].xpath('div/a/text()').text.strip.gsub(' , ', ', ')
                year = text.scan(/\d{4}/).flatten.last.to_i
                papers << {
                  year:year,
                  text: text,
                  id:id,
                }
              when 2 # It exists in ACM DL and has DOI
                id_path = td[2].xpath('div/a')[0].attr('href')
                doi_path = td[2].xpath('div/a')[1].attr('href')
                text = td[2].xpath('div/a')[0].text.strip.gsub(' , ', ', ')
                id = Rack::Utils.parse_query(URI.parse(id_path).query)['id']
                year = text.scan(/\d{4}/).flatten.last.to_i
                doi = URI.parse(doi_path).path.sub(/^\//, '')
                papers << {
                  year:year,
                  text:text,
                  id:id,
                  doi:doi,
                }
              else
                # TODO: error messages into the hash
                papers << {
                  error:td[2].text.strip
                }
              end
            end
            if papers.empty?
              return {}
            else
              return { references:papers }
            end
          end

          def read_citings(id)
            doc =  Nokogiri::HTML(open("http://dl.acm.org/tab_citings.cfm?id=#{id}"))
            papers = []
            doc.xpath('//table/tr/td/div/a').each do |link|
              paper = {}
              # id
              id_path = link.attr('href')
              if !id_path.nil? && !id_path.empty?
                paper[:id] = Rack::Utils.parse_query(URI.parse(id_path).query)['id']
              end
              # text
              text = link.text.strip
              text.gsub!(' , ', ', ')
              text.squeeze!(' ')
              if !text.empty?
                paper[:text] = text
              end
              # year
              year = text.scan(/\d{4}/).flatten.last.to_i
              if !year.zero?
                paper[:year] = year
              end
              # collect
              papers << paper
            end
            if papers.empty?
              return {}
            else
              return { citings:papers }
            end
          end

        end
      end
    end
  end
end
