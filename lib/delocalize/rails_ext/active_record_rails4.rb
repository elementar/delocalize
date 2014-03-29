ActiveRecord::Base.class_eval do
  def _field_changed?(attr, old, value)
    if I18n.delocalization_enabled? && value.kind_of?(String) && column = column_for_attribute(attr)
      value = column.delocalise_value(value)
    end
    super
  end
end

ActiveRecord::ConnectionAdapters::Column.class_eval do
  def delocalise_value(value)
    if date?
      Date.parse_localized(value) rescue value
    elsif time?
      Time.parse_localized(value) rescue value
    elsif number?
      Numeric.parse_localized(value) rescue value
    else
      value
    end
  end

  def type_cast_for_write_with_localization(value)
    type_cast_for_write_without_localization(I18n.delocalization_enabled? ? delocalise_value(value) : value)
  end

  alias_method_chain :type_cast_for_write, :localization
end
