RSpec.shared_examples_for 'an incomplete profile notifier' do
  it 'returns a flash message' do
    get :new, { event_slug: event.slug }
    expect(flash[:warning]).to be_present
  end

  it 'informs the user of the missing requirements' do
    get :new, { event_slug: event.slug }
    expect(flash[:warning]).to eq msg
  end
end
