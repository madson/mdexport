require 'spec_helper'
require 'file'

describe File do
  
  before do
    @filename = "#{__FILE__}.tmp"
  end
  
  it 'should delete a file' do
    FileUtils.touch @filename
    expect(File.exist?(@filename)).to eq(true)
    
    File.remove(@filename)
    expect(File.exist?(@filename)).to eq(false)
  end
  
end