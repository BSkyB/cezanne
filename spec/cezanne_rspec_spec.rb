require 'cezanne/rspec'
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.app = Rack::Directory.new('spec/images')
Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.include Cezanne
end


describe 'Cezanne RSpec integration', type: :feature, integration: true do

  before(:all) do 
    Cezanne.configure do |config| 
      config.uid = 'test'
      config.project_name = 'cezanne'
    end
  end

  context('Screenshot tests', screenshots: true) do 
     
    after(:all) do |example|
      RSpec.configuration.after(:all, screenshots: true).last.instance_variable_set(:@block, Proc.new {}) # disable the after(:all) hook  
      Cezanne.config.local_files.clean
    end
    
    before(:each) do |example|
      RSpec.configuration.before(:all, screenshots: true).first.run(example) unless example.metadata[:before_hook_test] 
    end

    after(:each) do |example|
      RSpec.configuration.after(:all, screenshots: true).last.run(example) unless example.metadata[:after_hook_test] 
      # the after(:all) hook that we just called will clean the local folders, so we need to recreate them so next test will find them
      Cezanne.config.local_files = Cezanne::LocalFiles.new(Cezanne.config.uid, Cezanne.config.local_root) 
    end

    describe 'initialization' do
     
      it 'create local folders' do 
        expect(File.exist?('artifacts/reference_screenshots')).to be true
        expect(File.exist?('artifacts/test/tmp_screenshots')).to be true 
        expect(File.exist?('artifacts/test/different_screenshots')).to be true 
        expect(File.exist?('artifacts/test/new_screenshots')).to be true 
      end
   

      it 'pull reference_screenshots' do 
        expect(File.exist?('artifacts/reference_screenshots/similar_firefox_34.0.5.gif')).to be true
        expect(File.exist?('artifacts/reference_screenshots/different_firefox_34.0.5.gif')).to be true
      end
      
      it 'create the remote reference folder if it does not exist', before_hook_test: true do  |example|
        allow(Cezanne.config.remote_files).to receive(:exists?).and_return(false)
        allow(Cezanne.config.remote_files).to receive(:push)
        expect(Cezanne.config.remote_files).to receive(:push).with(Cezanne.config.local_files.path_for(:ref), :ref);
        RSpec.configuration.before(:all, screenshots: true).first.run(example)  
      end 
    end 
    
    describe 'take screenshots' do 

      {phash_hamming_distance: 'phash hamming distance', peak_signal_to_noise_ratio: 'peak signal to noise ratio'}.each do |key, value|
     
       context value do  
          
          before(:all) do 
            Cezanne.config.similarity_threshold = nil
            Cezanne.configure do |config|
              config.comparison_method = key
            end
          end

          context 'similar' do

            it 'pass the test' do
              visit '/similar.html'
              expect { check_visual_regression_for 'similar' }.not_to raise_error
            end

          end
          
          context 'different' do

            it 'fail the test' do
              visit '/different.html'
              expect { check_visual_regression_for 'different' }.to raise_error
            end

          end

          
          context 'new' do

            it 'fail the test' do
              visit '/new.html'
              expect { check_visual_regression_for 'new' }.to raise_error
            end

          end

        end

      end 
    
    end

    describe 'finalization', after_hook_test: true do
      
      it 'push new, diff screenshots to remote' do |example|
        expect(Cezanne.config.remote_files).to receive(:push).with(kind_of(String), :diff).and_call_original
        expect(Cezanne.config.remote_files).to receive(:push).with(kind_of(String), :new).and_call_original
        RSpec.configuration.after(:all, screenshots: true).last.run(example)  
      end

      it 'does not push empty folders' do
        allow(Dir).to receive(:glob).and_return([])
        expect(Cezanne.config.remote_files).not_to receive(:push)
      end 


      it 'clean local folders' do |example|
        RSpec.configuration.after(:all, screenshots: true).last.run(example)
        expect(File.exists?('artifacts')).to be false
      end
      
    end

  end
end 
