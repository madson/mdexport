require 'spec_helper'
require 'string'

describe String do
  
  before do
    @filename = __FILE__
  end
  
  it 'should have a filename' do
    expect(@filename.filename).to eq('string_spec.rb')
  end
  
  it 'should have a extension' do
    expect(@filename.extension).to eq('.rb')
  end

  it 'should have a basename' do
    expect(@filename.basename).to eq('string_spec')
  end
  
  it 'should have a html file path' do
    dirname = Pathname.new(@filename).dirname
    expect(@filename.html_file_path).to eq("#{dirname}/string_spec.html")
  end
  
end