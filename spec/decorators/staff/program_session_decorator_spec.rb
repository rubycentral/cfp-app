require 'rails_helper'

describe Staff::ProgramSessionDecorator do
  describe '#complete_video_url' do
    it 'adds http to the url if not present' do
      program_session = FactoryBot.create(:program_session, video_url: "www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_video_url).to eq("http://www.example.com")
    end

    it 'does not add http if already present' do
      program_session = FactoryBot.create(:program_session, video_url: "http://www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_video_url).to eq("http://www.example.com")
    end

    it 'does not add https if already present' do
      program_session = FactoryBot.create(:program_session, video_url: "https://www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_video_url).to eq("https://www.example.com")
    end
  end

  describe '#complete_slides_url' do
    it 'adds http to the url if not present' do
      program_session = FactoryBot.create(:program_session, slides_url: "www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_slides_url).to eq("http://www.example.com")
    end

    it 'does not add http if already present' do
      program_session = FactoryBot.create(:program_session, slides_url: "http://www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_slides_url).to eq("http://www.example.com")
    end

    it 'does not add https if already present' do
      program_session = FactoryBot.create(:program_session, slides_url: "https://www.example.com")
      path = h.event_staff_program_session_path(program_session.event, program_session)
      data = Staff::ProgramSessionDecorator.decorate(program_session)

      expect(data.complete_slides_url).to eq("https://www.example.com")
    end
  end
end
