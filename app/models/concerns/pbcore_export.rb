module PbcoreExport
  def to_pbcore_xml
    doc = ExportPbcoreDatastream.new 
    title.each do |t|
      doc.title(t.title_type, t.value)
    end
    descMetadata.creator.each do |c|
      doc.insert_creator c.name.first, c.role.first
    end
    descMetadata.contributor.each do |c|
      doc.insert_contributor c.name.first, c.role.first
    end
    descMetadata.publisher.each do |c|
      doc.insert_publisher c.name.first, c.role.first
    end

    doc.subject = descMetadata.subject
    descMetadata.description.each do |d|
      doc.summary = d.value if d.type.first == 'summary'
    end

    descMetadata.event_location.each do |location|
      doc.insert_place(location, 'EVENT_LOCATION')
    end
    descMetadata.production_location.each do |location|
      doc.insert_place(location, 'PRODUCTION_LOCATION')
    end

    doc.insert_date(date_portrayed.first)
    doc.asset_date = date_created.first

    release_date.each do |date|
      doc.insert_release_date(date)
    end
    review_date.each do |date|
      doc.insert_review_date(date)
    end

    doc.asset_type = resource_type.to_a

    descMetadata.has_source.each do |src|
      doc.insert_relation(src.description.first, src.identifier.first)
    end

    length = descMetadata.rights_summary.size
    length = descMetadata.rights_holder.size if descMetadata.rights_holder.size > length
    0.upto(length) do |n|
      doc.insert_rights(descMetadata.rights_holder[n], descMetadata.rights_summary[n])
    end

    instantiation = build_instantiation

    doc.ng_xml.root.add_child instantiation.root.children

    doc.to_xml

  end

  def build_instantiation
    Nokogiri::XML::Builder.new do |xml|
      xml.root {
        xml.pbcoreInstantiation {
          language.each do |lang|
            xml.instantiationLanguage {
              xml.text lang
            }
          end
          xml.instantiationIdentifier {
            xml.text noid
          }
          xml.instantiationLocation {
            xml.text content.filename
          }
          # xml.instantiationDate(:dateType=>"created")
          # xml.instantiationDigital(:source=>"EBU file formats")
          if video?
            xml.instantiationMediaType(:source=>"PBCore instantiationMediaType") {
              xml.text "Moving Image"
            }
          elsif audio?
            xml.instantiationMediaType(:source=>"PBCore instantiationMediaType") {
              xml.text "Sound"
            }
          end
          # xml.instantiationGenerations(:source=>"PBCore instantiationGenerations")
          xml.instantiationFileSize(:unitsOfMeasure=>"") {
            xml.text file_size.first
          }
          xml.instantiationDuration {
            xml.text ffprobe.duration.first
          }
          # xml.instantiationColors(:source=>"PBCore instantiationColors") {
          #   xml.text "Color"
          # }

          0.upto(ffprobe.streams.stream.count - 1).each do |n|
            stream = ffprobe.streams.stream(n)
            xml.instantiationEssenceTrack {
              xml.essenceTrackType {
                xml.text stream.codec_type.first.capitalize if stream.codec_type.present?
              }
              xml.essenceTrackDataRate(:unitsOfMeasure=>"bps") {
                xml.text stream.bit_rate.first
              }
              xml.essenceTrackStandard {
                xml.text case stream.codec_long_name.first
                  when "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10"
                    "H.264/MPEG-4 AVC"
                  else
                    stream.codec_name.first.to_s.upcase
                  end
              }
              xml.essenceTrackEncoding(:source=>"PBCore essenceTrackEncoding")
              if stream.codec_type.first == 'video'
                xml.essenceTrackFrameRate(:unitsOfMeasure=>"fps") {
                  xml.text stream.frame_rate.first
                }
                xml.essenceTrackFrameSize(:source=>"PBCore essenceTrackFrameSize") {
                  xml.text "#{stream.width.first}x#{stream.height.first}"
                }
                xml.essenceTrackAspectRatio(:source=>"PBCore essenceTrackAspectRatio")
              elsif stream.codec_type.first == 'audio'
                xml.essenceTrackSamplingRate(:unitsOfMeasure=>"hz") {
                  xml.text stream.sample_rate.first
                }
                xml.essenceTrackBitDepth {
                  xml.text stream.bits_per_sample.first
                }
                xml.essenceTrackAnnotation(:annotationType=>"Number of Audio Channels") {
                  xml.text stream.channels.first
                }
              end
            }
          end

          xml.instantiationRights {
            xml.rightsSummary
          }
          
        }
      }
    end.doc
  end

end
