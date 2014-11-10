require 'ostruct'

module Homebrew
  def link
    raise KegUnspecifiedError if ARGV.named.empty?

    mode = OpenStruct.new

    mode.overwrite = true if ARGV.include? '--overwrite'
    mode.dry_run = true if ARGV.dry_run?

    ARGV.kegs.each do |keg|
      if keg.linked?
        opoo "Already linked: #{keg}"
        puts "To relink: brew unlink #{keg.name} && brew link #{keg.name}"
        next
      elsif keg_only?(keg.name) && !ARGV.force?
        opoo "#{keg.name} is not linked into #{HOMEBREW_PREFIX} by default."
        puts "To do so requires --force (which can interfere with building other packages)."
        next
      elsif mode.dry_run && mode.overwrite
        puts "Would remove:"
        keg.link(mode)

        next
      elsif mode.dry_run
        puts "Would link:"
        keg.link(mode)

        next
      end

      keg.lock do
        print "Linking #{keg}... "
        puts if ARGV.verbose?

        begin
          n = keg.link(mode)
        rescue Keg::LinkError
          puts
          raise
        else
          puts "#{n} symlinks created"
        end
      end
    end
  end

  private

  def keg_only?(name)
    Formulary.factory(name).keg_only?
  rescue FormulaUnavailableError
    false
  end
end
