require 'spec_helper'

describe RenderPipeline do
  describe '.render' do
    it 'should convert @ mentions to links' do
      result = subject.render('<div>@username</div>')
      expect(result).to eq('<div><a href="/username" class="user-mention">@username</a></div>')
    end

    it 'should convert @ mentions to links when the username starts with a dash' do
      result = subject.render('<div>@-username</div>')
      expect(result).to eq('<div><a href="/-username" class="user-mention">@-username</a></div>')
    end

    it 'should convert @ mentions to links when the username starts with an underscore' do
      result = subject.render('<div>@_username</div>')
      expect(result).to eq('<div><a href="/_username" class="user-mention">@_username</a></div>')
    end

    it 'should convert @ mentions to links when the username has a hyphen in it' do
      result = subject.render('<div>@user-name</div>')
      expect(result).to eq('<div><a href="/user-name" class="user-mention">@user-name</a></div>')
    end

    it 'should convert @ mentions to links when the username has an underscore in it' do
      result = subject.render('<div>@user_name</div>')
      expect(result).to eq('<div><a href="/user_name" class="user-mention">@user_name</a></div>')
    end
  end
end
