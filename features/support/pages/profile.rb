class Profile < Base
  def visit
    @page.visit(edit_profile_path)
  end

  def set_up_demographics_info(args={})
    demographics_info = default_demographics_info.merge(args)

    @page.fill_in 'person[gender]',
      with: demographics_info.fetch(:gender)
    @page.fill_in 'person[ethnicity]',
      with: demographics_info.fetch(:ethnicity)

    @page.select(demographics_info.fetch(:country),
      from: 'person[country]')
  end

  def submit_form
    @page.click_button 'Save'
  end

  def default_demographics_info
    {
      gender: 'female',
      ethnicity: 'Asian',
      country: 'United States of America'
    }
  end

  def changed_demographics_info
    {
      gender: 'not listed here',
      ethnicity: 'Caucasian',
      country: 'Germany'
    }
  end
end
