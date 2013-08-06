require 'formula'
require 'ostruct'

module Homebrew extend self
  def deps
    mode = OpenStruct.new(
      :installed?  => ARGV.include?('--installed'),
      :tree?       => ARGV.include?('--tree'),
      :all?        => ARGV.include?('--all'),
      :of_none?    => ARGV.include?('--of-none'),
      :of_any?     => ARGV.include?('--of-any'),
      :topo_order? => ARGV.include?('-n')
    )

    if mode.installed? && mode.tree?
      puts_deps_tree Formula.installed
    elsif mode.installed? && mode.of_any?
      all_deps = deps_of_any Formula.installed
      all_deps.sort! unless mode.topo_order?
      puts all_deps
    elsif mode.installed? && mode.of_none?
      puts deps_of_none Formula.installed
    elsif mode.installed?
      puts_deps Formula.installed
    elsif mode.all? && mode.of_any?
      all_deps = deps_of_any Formula
      all_deps.sort! unless mode.topo_order?
      puts all_deps
    elsif mode.all? && mode.of_none?
      puts deps_of_none Formula
    elsif mode.all?
      puts_deps Formula
    elsif mode.tree?
      raise FormulaUnspecifiedError if ARGV.named.empty?
      puts_deps_tree ARGV.formulae
    else
      raise FormulaUnspecifiedError if ARGV.named.empty?
      all_deps = deps_for_formulae ARGV.formulae
      all_deps.sort! unless mode.topo_order?
      puts all_deps
    end
  end

  def deps_for_formulae(formulae)
    formulae.map do |f|
      ARGV.one? ? f.deps.default : f.recursive_dependencies
    end.inject(&:&).map(&:name)
  end

  def deps_of_any(formulae)
    formulae.map do |f|
      ARGV.one? ? f.deps.default : f.recursive_dependencies
    end.flatten.map(&:name).uniq
  end

  def deps_of_none(formulae)
    formulae.map(&:name) - deps_of_any(formulae)
  end

  def puts_deps(formulae)
    formulae.each { |f| puts "#{f.name}: #{f.deps*' '}" }
  end

  def puts_deps_tree(formulae)
    formulae.each do |f|
      puts f.name
      recursive_deps_tree(f, 1)
      puts
    end
  end

  def recursive_deps_tree f, level
    f.deps.default.each do |dep|
      puts "|  "*(level-1)+"|- "+dep.to_s
      recursive_deps_tree(Formula.factory(dep.to_s), level+1)
    end
  end
end
